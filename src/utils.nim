import std/[os, strformat, strutils]

proc recurseList*(filePath: string): seq[string] =
  ## Recursively list all files in a directory, excluding hidden files.
  ## @param filePath The root directory path from which to start listing files.
  ## @return A sequence of relative file paths.
  echo &"DEBUG: recurse listing {filePath}"
  for kind, path in walkDir(filePath):
    if ((path.contains("/") and path.split("/")[^1].startsWith(".")) or (not path.contains("/") and path.startsWith("."))):
      continue
    elif {pcFile, pcLinkToFile}.contains(kind):
      result.add(path)
    elif {pcDir, pcLinkToDir}.contains(kind):
      result.add(recurseList(path))


when isMainModule:
  var result = recurseList(".")

  for file in result:
    echo file