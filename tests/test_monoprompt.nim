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
    let m = parseMonoprompt(testFolder / "life.monoprompt")
    assert m.len() == 1, "Expected 1 monoprompt"
    for mp in m:
      mp.execute()
    assert fileExists(testFolder / "life.txt"), "Expected life.txt to exist"
  test "fibonacci":
    let output = testFolder / "fibonacci.nim"
    if fileExists(output):
      removeFile(output)
    let m = parseMonoprompt(testFolder / "fibonacci.monoprompt")
    assert m.len() == 1, "Expected 1 monoprompt"
    for mp in m:
      mp.execute()
    assert fileExists(output), "Expected fibonacci.nim to exist"
    # ensure the file compiles
    let res = execCmd(&"nim c {output}")
    assert res == 0, "Expected fibonacci.nim to compile"
