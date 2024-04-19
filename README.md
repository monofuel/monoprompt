# [monoprompt](https://monofuel.github.io/monoprompt/)

A LLM project that aims to allow for fine-grain control of using LLMs to generate individual files.

Inspired by Dockerfiles, monoprompts are a way to orchestrate LLMs to generate text files.
A monoprompt contains the name of the file(s) to output, the LLM model to use, supporting context files, and the prompt.
- monoprompts might output code, documentation, or any other text file.

- Sample prompt:
```md
# fibonacci.nim

## config

model: gpt-3.5-turbo

## prompt

Please generate a Nim file with a single nim function to calculate fibonacci numbers recursively.

`proc fib*(n: int): int =`

At the end of the file, include a `when isMainModule:` block with tests for how to run the function.
```


- OPENAI_API_KEY must be set, to use the OpenAI API.
  - currently only openAI and Ollama are supported.
- You can create a monoprompt by running `./monoprompt --create example.txt`
  - this command will create `example.txt.monoprompt` in the current directory.
- You can run a monoprompt by running `./monoprompt example.txt.monoprompt`

example use cases:

- building new code files while referencing existing code files for imports, architecture, and code style
- generate docs for a codebase by referencing code files
- generate tests for an existing codebase by referencing the code they need to test
- generate a summary of files in a folder
- generate a workout plan based on previous workout notes


## Specification

- monoprompts are a markdown file with a `.monoprompt` extension.
- start the file with a header of the output filename.
- a monoprompt file can contain multiple headers, to generate multiple files.
- each file may have an optional `## Config` section, which will contain a YAML config object (ew)
- each file will have an `## Prompt` section, which will contain the prompt for the LLM.
- There may be a project top level `monoprompt.yaml` file of cross project configuration.

  - this config object will be merged with the config object in each file.

- configuration
  - context: a list of files to use as context for the LLM
    - If you provide a directory, a directory listing will be used as context.
    - you can use `./...` to recursively list the directory
    - wildcards are not implemented yet (TODO)
  - model: the LLM model to use
  - depends: list of promptfiles that this prompt depends on
  - output: "overwrite", "augment" or "append"
    - overwrite: overwrite the file
    - augment: include the existing file as context and re-write the file with augmentations
    - append: add to the file, but only if the file doesn't already exist
    - noop: do nothing. this may be useful if you manually edited the output, but don't want to overwrite and don't want to mess with prompt dependencies.

```md
# example.nim

## Config
context:
  - ./readme.md
  - ./programming-patterns.md
  - ./otherfile.nim
  - ./
model: gpt-3.5-turbo

## prompt

Please generate a Nim file with a single nim function to calculate fibonacci numbers recursively.

`proc fib\*(n: int): int =`

At the end of the file, include a `when isMainModule:` block with tests for how to run the function.
```

## Environment

- set `OPENAI_API_KEY` to your OpenAI API key if you want to use the OpenAI API.

## Fine-Tuning

- TODO not implemented yet

- projects with both monoprompts and their document output can be further fine-tuned, as we have both instructions and the output to train on.
- This can be very useful to incrementally train models on existing codebases by introducing monoprompts to instruct the model with.

## Plugin system

- TODO not implemented yet

- monoprompts can be extended with plugins that hook into different stages of the monoprompt generation process.

### Post-Processor

- TODO not implemented yet

- post-processors can be used to modify the output of a monoprompt.
- for example, we could try to run a compiler on the output and then run the compiler errors through another LLM to automatically correct them.

### Dynamic Context

- TODO not implemented yet

- dynamic context via executable plugins
- a plugin is a binary or script that can take in a json object, and return a json object response with an array of context objects
- This way monoprompts can interact with arbitrary RAG or search systems


# Testing

- run `nimble test` to run unit tests
- run `nim c -r tests/integration.nim` to run integration tests
  - OPENAI_API_KEY must be set to run integration tests
  - if you are adventurous, modify the test prompts for ollama to run locally.