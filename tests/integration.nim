import std/[unittest, os, strformat, osproc], monoprompt, ai

const testFolder = "tests/monoprompts/"

suite "monoprompt":
  setup:
    ai.setup()
  teardown:
    ai.close()

  test "life":
    if fileExists(testFolder / "life.txt"):
      removeFile(testFolder / "life.txt")
    let m = readMonoprompt(testFolder / "life.monoprompt")
    assert m.len() == 1, "Expected 1 monoprompt"
    for mp in m:
      mp.execute()
    assert fileExists(testFolder / "life.txt"), "Expected life.txt to exist"

  test "fibonacci":
    let output = testFolder / "fibonacci.nim"
    if fileExists(output):
      removeFile(output)
    let m = readMonoprompt(testFolder / "fibonacci.monoprompt")
    assert m.len() == 1, "Expected 1 monoprompt"
    for mp in m:
      mp.execute()
    assert fileExists(output), "Expected fibonacci.nim to exist"
    # ensure the file compiles
    let res = execCmd(&"nim c {output}")
    assert res == 0, "Expected fibonacci.nim to compile"

  test "call_fibonacci":
    let output = testFolder / "call_fibonacci.nim"
    if fileExists(output):
      removeFile(output)
    let m = readMonoprompt(testFolder / "call_fibonacci.monoprompt")
    assert m.len() == 1, "Expected 1 monoprompt"
    assert m[0].config.context.len == 1, "Expected 1 context"
    for mp in m:
      mp.execute()
    assert fileExists(output), "Expected call_fibonacci.nim to exist"
    # ensure the file compiles
    let res = execCmd(&"nim c {output}")
    assert res == 0, "Expected call_fibonacci.nim to compile"
