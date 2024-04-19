import std/[unittest, os, strformat, osproc], monoprompt, ai

const testFolder = "tests/monoprompts/"

suite "monoprompt parsing":
  setup:
    ai.setup()
  teardown:
    ai.close()

  test "life":
    if fileExists(testFolder / "life.txt"):
      removeFile(testFolder / "life.txt")
    let m = parseMonoprompt(testFolder / "life.monoprompt")
    assert m.len() == 1, "Expected 1 monoprompt"


  test "fibonacci":
    let output = testFolder / "fibonacci.nim"
    if fileExists(output):
      removeFile(output)
    let m = parseMonoprompt(testFolder / "fibonacci.monoprompt")
    assert m.len() == 1, "Expected 1 monoprompt"


  test "call_fibonacci":
    let output = testFolder / "call_fibonacci.nim"
    if fileExists(output):
      removeFile(output)
    let m = parseMonoprompt(testFolder / "call_fibonacci.monoprompt")
    assert m.len() == 1, "Expected 1 monoprompt"
    assert m[0].config.context.len == 1, "Expected 1 context"

