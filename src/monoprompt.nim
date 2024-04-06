
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

  echo "Usage: monoprompt <promptfile> (<promptfile>...)"
  echo ""
  echo "check \t\tvalidate loading in the monoprompt files"
  echo "dryrun \t\tdo a dry run without running the LLM or producing output"
  echo ""
  echo "version  \t\tprint version"
  echo "help       \t\tprint this help"

proc printVersion() =
  echo "Racha version 1.0.1"

proc parseMonoprompt*(filename: string): seq[Monoprompt] =
  result = @[]

proc main() =
  echo "hello world"




when isMainModule:
  main()
