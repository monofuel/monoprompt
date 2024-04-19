import std/os, std/strformat

proc recurseList*(filePath: string): seq[string] =
  ## Recursively list all files in a directory.
  ## returns a list of relative file paths
  echo &"DEBUG: {filepath}"
  for kind, path in walkDir(filePath):
    if {pcFile, pcLinkToFile}.contains(kind):
      result.add(path)
    elif {pcDir, pcLinkToDir}.contains(kind):
      result.add(recurseList(path))


when isMainModule:
  let files = recurseList(".")

  for file in files:
    echo file