import std/[os, strutils, strformat], llama_leap, openai_leap

var
  openai: OpenAIAPI
  ollama: OllamaAPI

proc setup*() =
  let openAIKey = getEnv("OPENAI_API_KEY", "")
  if openAIKey != "":
    echo &"DEBUG: OpenAI API key found, initializing OpenAI API"
    openai = newOpenAIAPI()
  ollama = newOllamaAPI()

proc close*() =
  ollama.close()
  openai.close()

proc generateCompletion*(model: string, system: string,
    prompt: string): string =
  echo &"DEBUG: model: {model}"
  echo &"DEBUG: prompt: {prompt}"

  if model.startsWith("gpt-"):
    if openai == nil:
      raise newException(Exception, "OpenAI API not initialized")
    echo &"DEBUG: Generating completion using OpenAI {model}"
    result = openai.createChatCompletion(model, system, prompt)
  else:
    echo &"DEBUG: Generating completion using Ollama {model}"
    result = ollama.generate(model, system & "\n" & prompt)
