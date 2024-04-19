version     = "1.0.10"
author      = "Andrew Brower"
description = "monoprompt project"
license     = "MIT"

srcDir = "src"
bin = @["monoprompt"]

requires "nim >= 2.0.0"
requires "curly >= 0.1.12"
requires "jsony >= 1.1.5"
requires "yaml >= 2.0.0"

requires "https://github.com/monofuel/llama_leap >= 1.0.1"
requires "https://github.com/monofuel/openai_leap >= 1.0.1"
# requires "https://github.com/monofuel/mono_finetune >= 0.1.0"

task build, "Build the project":
  exec "nimble c -d:ssl -d:release src/monoprompt.nim"
