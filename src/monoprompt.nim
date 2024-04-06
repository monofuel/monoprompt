import std/[os, strutils, strformat, json], jsony, yaml/[loading]


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
  filename*: string
  config*: MonopromptConfig
  prompt*: string


proc printHelp() =

  echo "Usage: monoprompt <promptfile>"
  echo ""
  #echo "--check \t\tvalidate loading in the monoprompt files"
  #echo "--dryrun \t\tdo a dry run without running the LLM or producing output"
  # echo ""
  echo "  --version  \t\tprint version"
  echo "  --help     \t\tprint this help"

proc printVersion() =
  echo "Monoprompt version 0.1.1"

proc parseMonoprompt*(filename: string): seq[Monoprompt] =
  let promptContent = readFile(filename)
  let lines = promptContent.splitLines
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
    result.add(currentFile)

  for p in result:
    if p.prompt == "":
      raise newException(Exception, &"No prompt found in monoprompt file for {p.filename}")
  if result.len == 0:
    echo "No monoprompt prompts found"


proc main() =
  let args = commandLineParams()
  if args.len == 0 or args[0] == "--help" or args[0] == "-h":
    printHelp()
    return
  if args[0] == "--version" or args[0] == "-v":
    printVersion()
    return

  echo "DEBUG: args ", toJson(args)

  let filepath = args[0]

  let (head, tail) = splitPath(filepath)
  echo "DEBUG: head ", head
  echo "DEBUG: tail ", tail

  let monoprompts = parseMonoprompt(filepath)
  echo "DEBUG: monoprompts.len ", monoprompts.len
  echo "DEBUG: monoprompts ", toJson(monoprompts)


when isMainModule:
  main()
