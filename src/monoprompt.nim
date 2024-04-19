import std/[os, strutils, strformat, json],
  jsony, yaml/[loading], ./ai, utils

var
  check = false
  execDepends = false

const
  NimblePkgVersion {.strdefine.} = "dev"
  Version = NimblePkgVersion

const ExamplePromptfile = staticRead("../tests/monoprompts/life.monoprompt")

type MonopromptOutput* = enum
  ## What strategy to use when writing the output file
  undef, # default 1st enum for undefined types
  overwrite,
  augment,
  append,
  noop

type MonopromptConfig* = ref object
  ## Configuration for a monoprompt file
  model*: string
  context* {.defaultVal: @[].}: seq[string]
  depends* {.defaultVal: @[].}: seq[string]
  output*{.defaultVal: overwrite.}: MonopromptOutput

type Monoprompt* = ref object
  ## structure for a monoprompt file
  promptFilename*: string
  promptDir*: string
  filename*: string
  config*: MonopromptConfig
  prompt*: string


proc printHelp() =
  echo "Usage: monoprompt <promptfile>"
  echo ""
  echo "--check \t\tvalidate loading in the monoprompt files"
  echo "--create <output-filename> \t\tcreate a new monoprompt file with a basic template"
  echo "--exec-depends <promptfile> \t\texecute dependencies of the monoprompt files"
  echo ""
  echo "  --version  \t\tprint version"
  echo "  --help     \t\tprint this help"

proc printVersion() =
  echo &"Monoprompt version {Version}"

proc parseMonoprompt*(filename,content: string): seq[Monoprompt] =
  ## Parse the contents of a monoprompt file.
  ## file is passed as args, no fs reads or writes are done.
  let lines = content.splitLines
  let (head, tail) = splitPath(filename)
  echo "DEBUG: head ", head
  echo "DEBUG: tail ", tail
  var
    currentFile = Monoprompt()
    currentSection = ""
    config = ""

  for line in lines:
    if line.startsWith("!#"):
      echo &"DEBUG: Skipping shebang {line}"
      continue
    elif line.startsWith("# "):
      let filename = line[2..^1] # Remove '# ' prefix
      if currentFile.filename != "":
        if config != "":
          load(config, currentFile.config)
          config = ""
        currentFile.promptFilename = filename
        currentFile.promptDir = head
        result.add(currentFile)
        currentFile = Monoprompt()
      else:
        currentFile.filename = filename
    elif line.toLower.startsWith("## "):
      # TODO should probably ignore ## in ``` code blocks
      # Identify the current section
      currentSection = line[3..^1].toLower.strip
    else:
      case currentSection
      of "config":
        config.add(line & "\n")
      of "prompt":
        if line.strip != "":
          currentFile.prompt.add(line & "\n") # Append line to prompt, preserving line breaks
      of "":
        discard
      else:
        raise newException(Exception, &"Unrecognized section {currentSection}")

  if currentFile.filename != "":
    if config != "":
      load(config, currentFile.config)
      config = ""
    currentFile.promptFilename = filename
    currentFile.promptDir = head
    result.add(currentFile)

  for p in result:
    if p.prompt == "":
      raise newException(Exception, &"No prompt found in monoprompt file for {p.filename}")
  if result.len == 0:
    echo "No monoprompt prompts found"

proc readMonoprompt*(filename: string): seq[Monoprompt] =
  ## Read a monoprompt file and parse it
  let content = readFile(filename)
  return parseMonoprompt(filename, content)


proc execute*(mp: Monoprompt) =
  let c = mp.config
  ## Execute a parsed monoprompt.
  ## iterates over all the outputs in the monoprompt and
  ## executes them with the specified LLM in the config.
  echo &"DEBUG: Processing {mp.filename}"

  if c.depends.len > 0:
    # iterate through dependencies and see if they have been executed yet
    for dep in c.depends:
      if dep.contains("*"):
        # TODO implement wildcards for dependencies
        raise newException(Exception, &"Wildcards not yet implemented")
      let depFilepath = mp.promptDir / dep
      let depInfo = getFileInfo(depFilepath)
      if depInfo.kind != pcFile:
        raise newException(Exception, &"Dependency {dep} not found")
      let depMonoprompts = readMonoprompt(depFilepath)
      echo &"DEBUG: Found {depMonoprompts.len} dependencies for {mp.filename}"
      for depMp in depMonoprompts:
        # test if the outputs exist
        let depOutputFilepath = mp.promptDir / depMp.filename
        let exists = fileExists(depOutputFilepath)
        if not exists:
          # TODO should assert the output is a file
          if execDepends:
            echo &"DEBUG: Executing dependency {depMp.filename}"
            execute(depMp)
          else:
            raise newException(Exception, &"Dependency output {depMp.filename} not built. use `--exec-depends` if you want to build dependencies")



  if c.output == noop:
    echo &"DEBUG: Noop mode, skipping {mp.filename}"
    return

  if c.output == undef:
    # likely some sort of invalid enum when loading
    raise newException(Exception, &"Output mode not defined for {mp.filename}")

  echo &"Processing output {mp.filename}"

  var system = &"""
You are A helpful AI Assitant with a duty to generate files.
Please respond only with the contents of the file.
You will be given context, and a prompt.
"""
  if c.output == augment:
    system &= "You will be augmenting a file that already exists. It will be provided as <ExistingFile/>."

  for contextFile in c.context:

    if contextFile.endsWith"/...":
      echo &"DEBUG: Reading all files in directory {mp.promptDir}"
      # list all files recursively
      var recurseFilepath = contextFile
      recurseFilepath.removeSuffix("/...")
      recurseFilepath = mp.promptDir / recurseFilepath

      let files = recurseList(recurseFilepath)
      let filesStr = files.join("\n")
      echo &"DEBUG: Found {files.len} files, recurive listing {recurseFilepath}"
      system.add(&"<ContextDir>\n{filesStr}\n</ContextDir>\n")

      continue


    let contextFilepath = mp.promptDir / contextFile

    if contextFilepath.contains("*"):
      # TODO handle wildcards for context
      raise newException(Exception, &"Wildcards not yet implemented")

    # check if it is a file or directory
    let ctxInfo = getFileInfo(contextFilepath)
    case ctxInfo.kind:
    of pcFile, pcLinkToFile:
      echo &"DEBUG: Reading context from {contextFilepath}"
      let c = readFile(contextFilepath)
      system.add(&"<Context>\n{c}\n</Context>\n")
    of pcDir, pcLinkToDir:
      echo &"DEBUG: Reading directory listing {contextFilepath}"
      var files: seq[string]
      for (_, filename) in walkDir(contextFilepath):
        let info = getFileInfo(filename)
        if info.kind == pcFile:
          files.add(filename)
      let filesStr = files.join("\n")
      system.add(&"<ContextDir>\n{filesStr}\n</ContextDir>\n")
    

  # TODO handle dynamic context plugins

  if check:
    return


  let outputFilepath = mp.promptDir / mp.filename
  if c.output == augment:
    if not fileExists(outputFilepath):
      raise newException(Exception, &"Augment mode requires an existing file {outputFilepath}")

    let existingFile = readFile(outputFilepath)
    system.add(&"<ExistingFile>\n{existingFile}\n</ExistingFile>\n")

  case c.output:
  of overwrite,augment:
    var fileOutput = generateCompletion(
      c.model,
      system.strip,
      mp.prompt.strip
    )

    # LLMs sometimes really like using codeblocks, let's just strip them out
    var lines = fileOutput.split("\n")
    # Remove the first line if it starts with ```
    if lines.len > 0 and lines[0].startsWith("```"):
      lines = lines[1..^1]
    # Remove the last line if it is ```
    if lines.len > 0 and lines[^1] == "```":
      lines = lines[0..^2]
    fileOutput = lines.join("\n")

    echo &"{c.output} to {outputFilepath}"
    writeFile(outputFilepath, fileOutput)
  of append:
    var fileOutput = generateCompletion(
      c.model,
      system.strip,
      mp.prompt.strip
    )

    # LLMs sometimes really like using codeblocks, let's just strip them out
    var lines = fileOutput.split("\n")
    # Remove the first line if it starts with ```
    if lines.len > 0 and lines[0].startsWith("```"):
      lines = lines[1..^1]
    # Remove the last line if it is ```
    if lines.len > 0 and lines[^1] == "```":
      lines = lines[0..^2]
    fileOutput = lines.join("\n")

    echo &"appending to {outputFilepath}"
    let file = open(outputFilepath, fmAppend)
    file.write(fileOutput)
    file.write("\n")
    file.close()
    
  else:
    raise newException(Exception, &"Output mode not implemented {c.output}")

proc main() =
  ## CLI main function.
  ## parses command line arguments and executes the monoprompt files
  var args = commandLineParams()

  if args.len == 0 or args[0] == "--help" or args[0] == "-h":
    printHelp()
    return
  if args[0] == "--version" or args[0] == "-v":
    printVersion()
    return

  if args[0] == "--check" or args[0] == "-c":
    echo &"DEBUG: check"
    check = true
    args = args[1..^1]

  if args[0] == "--exec-depends":
    echo &"DEBUG: execDepends"
    execDepends = true
    args = args[1..^1]

  if args[0] == "--create":
    if args.len < 2:
      echo "Error: --create requires a filename"
      return
    var filename = args[1]
    if filename.endsWith(".monoprompt"):
      filename = filename[0..^12]
    var sampleOutput = ExamplePromptfile
    sampleOutput = sampleOutput.replace("life.txt", filename)

    writeFile(filename & ".monoprompt", sampleOutput)
    return

  ai.setup()

  echo "DEBUG: promptfiles ", toJson(args)
  echo &"DEBUG: check: {check}"

  let filepath = args[0]

  # TODO handle multiple files
  # TODO handle wildcards
  # TODO should re-order the files based on dependencies

  echo &"DEBUG: Parsing {filepath}"
  let monoprompts = readMonoprompt(filepath)
  echo "DEBUG: monoprompts.len ", monoprompts.len
  echo "DEBUG: monoprompts ", toJson(monoprompts)

  for mp in monoprompts:
    execute(mp)

  ai.close()

  if check:
    echo "Check complete, no errors found"
  else:
    echo &"Monoprompt {filepath} complete"


when isMainModule:
  main()
