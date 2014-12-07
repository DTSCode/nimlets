import os
from strutils import endsWith
import parse_snippets
import threadPool

let args = commandLineParams()
if args.len != 2:
  echo "syntax error"
  echo "gensnippets <snippet dir> <target dir>"
  quit(QuitFailure)

let snippetDir = args[0]
let targetDir = args[1]


var snippetChannel: TChannel[Snippet]
open(snippetChannel)

import templates.snippet
proc processSnippet(filename: string) =
  let snippet = parseSnippet(readFile(filename))
  snippetChannel.send(snippet)
  let renderedSnippet = renderSnippetPage(snippet)
  let targetFilename = targetDir / splitFile(filename).name.addFileExt("html")
  targetFilename.writeFile(renderedSnippet)


for file in walkDirRec(snippetDir, filter = {pcFile,
                                             pcLinkToFile,
                                             pcDir,
                                             pcLinkToDir}):
  if file.endsWith(".nim"):
    spawn processSnippet(file)


sync()

var snippets: seq[Snippet] = @[]

while true:
  snippets.add(snippetChannel.recv())
  # single consumer, no races
  if snippetChannel.peek == -1:
    break

