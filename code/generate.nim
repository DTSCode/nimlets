import os
from strutils import endsWith
import parse_snippets
import threadPool
import generate_stats


let args = commandLineParams()

cast[proc() {.gcsafe.}](proc () = discard args)()

if args.len != 2:
  echo "syntax error"
  echo "gensnippets <snippet dir> <target dir>"
  quit(QuitFailure)


let snippetDir = args[0]
let targetDir = args[1]


var snippetChannel: TChannel[Snippet]
open(snippetChannel)

import templates.snippet
proc processSnippetBase(filename: string, numId: int) =
  let snippet = parseSnippet(readFile(filename), numId)
  snippetChannel.send(snippet)
  let renderedSnippet = renderSnippetPage(snippet)
  let targetFilename = targetDir / snippet.id & ".html"
  echo renderedSnippet
  targetFilename.writeFile(renderedSnippet)

let processSnippet = cast[proc (f: string, i: int) {.gcsafe.}](processSnippetBase)


for file in walkDirRec(snippetDir, filter = {pcFile,
                                             pcLinkToFile,
                                             pcDir,
                                             pcLinkToDir}):
  var numId = 0
  if file.endsWith(".nim"):
    inc numId
    spawn processSnippet(file, numId)


sync()

var snippets: seq[Snippet] = @[]

# single consumer, no races
while snippetChannel.peek != 0:
  echo snippetChannel.peek()
  snippets.add(snippetChannel.recv())

(targetDir / "search_index.json").writeFile(analyzeAndRender(snippets))
