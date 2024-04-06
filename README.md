# monoprompt

- WIP

- A LLM project that aims to allow for fine-grain control of using LLMs to generate individual files.

- Inspired by Dockerfiles, monoprompts are a way to orchestrate LLMs to generate text files.
- A monoprompt contains the name of the file(s) to output, the LLM model to use, supporting context files, and the prompt.
- monoprompts might output code, documentation, or any other text file.
- monoprompts may depend on the output of other monoprompts.

- example use cases:

  - generate docs for a codebase
  - generate tests for an existing codebase
  - generate a summary of files in a folder
  - generate a workout plan based on previous workout notes

- long term goals:
  - It could be exciting if you could generate entire projects from a single monoprompt.
  - monoprompts to generate other monoprompts
  - entire codebases could be generated in different languages with a single line change of what language to use.
  - generate your own libraries using nothing but an RFC or API.

## Specification

- yaml? md?
- I'm sick of yaml. I want to use markdown.

- start the file with a header of the output filename.
- a monoprompt file can contain multiple headers, to generate multiple files.
- each file may have an optional `## config` section, which will contain a YAML config object (ew)
- each file will have an `## Input` section, which will contain the prompt for the LLM.
- There may be a project top level `monoprompt.yaml` file of cross project configuration.

  - this config object will be merged with the config object in each file.

- configuration
  - context: a list of files to use as context for the LLM
    - stretch goal: support URLs
  - model: the LLM model to use
  - depends: list of promptfiles that this prompt depends on
  - output: "overwrite", "augment" or "append"
    - overwrite: overwrite the file
    - augment: add to the file
    - append: add to the file, but only if the file doesn't already exist

```monoprompt
# example.nim

## Config
context:
  - ./readme.md
  - ./programming-patterns.md
  - ./otherfile.nim
model: gemini-1.0-pro-001

## Input

Please generate a Nim file with a single nim function to calculate fibonacci numbers recursively.

`proc fib\*(n: int): int =`

At the end of the file, include a `when isMainModule:` block with tests for how to run the function.
```

## Fine-Tuning

- projects with both monoprompts and their document output can be further fine-tuned, as we have both instructions and the output to train on.
- This can be very useful to incrementally train models on existing codebases.

## Plugin system

- monoprompts can be extended with plugins that hook into different stages of the monoprompt generation process.

### Post-Processor

- post-processors can be used to modify the output of a monoprompt.
- for example, we could try to run a compiler on the output and then run the compiler errors through another LLM to automatically correct them.

### Dynamic Context

- dynamic context via executable plugins
- a plugin is a binary or script that can take in a json object, and return a json object response with an array of context objects
- This way monoprompts can interact with arbitrary RAG or search systems
