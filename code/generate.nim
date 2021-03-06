import os
from strutils import endsWith, `%`
import parse_snippets
import threadPool
import templates.index
import tables

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
proc processSnippetBase(filename: string) =
  echo("rendering $1" % [filename])

  let snippet = parseSnippet(readFile(filename))
  snippetChannel.send(snippet)
  let renderedSnippet = renderSnippetPage(snippet)
  let targetFilename = targetDir / snippet.id & ".html"
  targetFilename.writeFile(renderedSnippet)

let processSnippet = cast[proc (f: string) {.gcsafe.}](processSnippetBase)


for file in walkDirRec(snippetDir, filter = {pcFile,
                                             pcLinkToFile,
                                             pcDir,
                                             pcLinkToDir}):
  if file.endsWith(".nim"):
    spawn processSnippet(file)


sync()

var snippets: seq[Snippet] = @[]

# single consumer, no races
while snippetChannel.peek != 0:
  snippets.add(snippetChannel.recv())

import templates.document_index
import templates.sitemap
(targetDir / "document_index.json").writeFile(renderDocumentIndex(snippets))
(targetDir / "index.html").writeFile(renderHome())
(targetDir / "sitemap.html").writeFile(renderSitemap(snippets))
