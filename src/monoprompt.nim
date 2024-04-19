import std/[os, strutils, strformat, json],
  jsony, yaml/[loading], ./ai

var
  check = false

const ExamplePromptfile = staticRead("../tests/monoprompts/life.monoprompt")

type MonopromptOutput* = enum
  overwrite,
  augment,
  append

type MonopromptConfig* = ref object
  model*: string
  context* {.defaultVal: @[].}: seq[string]
  depends* {.defaultVal: @[].}: seq[string]
  output*{.defaultVal: overwrite.}: MonopromptOutput

type Monoprompt* = ref object
  promptFilename*: string
  promptDir*: string
  filename*: string
  config*: MonopromptConfig
  prompt*: string


proc printHelp() =

  echo "Usage: monoprompt <promptfile>"
  echo ""
  echo "--check \t\tvalidate loading in the monoprompt files"
  echo "--create <filename> \t\tcreate a new monoprompt file with a basic template"
  echo ""
  echo "  --version  \t\tprint version"
  echo "  --help     \t\tprint this help"

proc printVersion() =
  echo "Monoprompt version 1.0.3"

proc parseMonoprompt*(filename: string): seq[Monoprompt] =
  let promptContent = readFile(filename)
  let lines = promptContent.splitLines
  let (head, tail) = splitPath(filename)
  echo "DEBUG: head ", head
  echo "DEBUG: tail ", tail
  var
    currentFile = Monoprompt()
    currentSection = ""
    config = ""

  for line in lines:
    if line.startsWith("# "):
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


proc execute*(mp: Monoprompt) =
  echo &"Processing {mp.filename}"

  echo &"Processing output {mp.filename}"
  if mp.config.output != overwrite:
    raise newException(Exception, "Output mode not yet implemented")

  var system = &"""
You are A helpful AI Assitant with a duty to generate files.
Please respond only with the contents of the file.
You will be given context, and a prompt.
"""
  for contextFile in mp.config.context:
    let contextFilepath = mp.promptDir / contextFile
    echo &"DEBUG: Reading context from {contextFilepath}"
    let c = readFile(contextFilepath)
    system.add(&"<Context>\n{c}\n</Context>\n")

  # TODO handle dynamic context plugins
  # TODO handle depends

  if check:
    return
  var fileOutput = generateCompletion(
    mp.config.model,
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

  let outputFilepath = mp.promptDir / mp.filename
  echo &"Writing to {outputFilepath}"
  writeFile(outputFilepath, fileOutput)

proc main() =
  var args = commandLineParams()

  if args.len == 0 or args[0] == "--help" or args[0] == "-h":
    printHelp()
    return
  if args[0] == "--version" or args[0] == "-v":
    printVersion()
    return

  if args[0] == "--check" or args[0] == "-c":
    check = true
    args = args[1..^1]
  if args[0] == "--create":
    if args.len < 2:
      echo "Error: --create requires a filename"
      return
    var filename = args[1]
    if not filename.endsWith(".monoprompt"):
      filename = filename & ".monoprompt"
    var sampleOutput = ExamplePromptfile
    sampleOutput = sampleOutput.replace("life.txt", filename)

    writeFile(filename, sampleOutput)
    return

  ai.setup()

  echo "DEBUG: promptfiles ", toJson(args)
  echo &"DEBUG: check: {check}"

  let filepath = args[0]

  # TODO handle multiple files
  # TODO handle wildcards

  echo &"Parsing {filepath}"
  let monoprompts = parseMonoprompt(filepath)
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
