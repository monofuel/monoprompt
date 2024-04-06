import std/[os], jsony


type MonopromptOutput* = enum
  overwrite,
  augment,
  append

type MonopromptConfig* = ref object
  model*: string
  context*: seq[string]
  depends*: seq[string]
  output*: MonopromptOutput

type Monoprompt* = ref object
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
  result = @[]

proc main() =
  let args = commandLineParams()
  if args.len == 0 or args[0] == "--help" or args[0] == "-h":
    printHelp()
    return
  if args[0] == "--version" or args[0] == "-v":
    printVersion()
    return
  echo toJson(args)



when isMainModule:
  main()
