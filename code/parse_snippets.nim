from os import commandLineParams
from strutils import splitLines, `%`, strip
from re import `=~`, re

type
  FileSection {.pure.} = enum InStart, InHeader, InRest

proc splitHeader(text: string): tuple[header, rest: string] =
  var header = ""
  var rest   = ""

  var state = FileSection.InStart

  for line in splitLines(text):
    # if used instead of case so that multiple states can be
    # executed for the same line

    if state == FileSection.InStart:
      if strip(line) == "":  # blank line
        continue
      elif line =~ re"^\#\#.*+$":  # special comment
        state = FileSection.InHeader
      else:  # something else -- this file doesn't
             # have a header
        state = FileSection.InRest

    if state == FileSection.InHeader:
      if line =~ re"^\#\#[ ]?(.*+$)":
        header.add(matches[0] & "\n")
      else:
        state = FileSection.InRest

    if state == FileSection.InRest:
      rest.add(line & "\n")

  return (header, rest)

type
  Snippet* = object
    title*: string
    author*: string
    tags*: seq[string]
    description*: string
    code*: string

proc parseMetadata(header: string): Snippet =
  discard

proc parseSnippet*(text: string): Snippet =
  let (metadata, rest) = splitHeader(text)
  let (description, code) = splitHeader(rest)

  result = parseMetadata(metadata)
  result.code = code
  result.description = description


when defined(test):
  doAssert(splitHeader("""
## 123
## ##

## foo bar
echo 1+2
""") == ("123\n##\n", "\n## foo bar\necho 1+2\n\n"))
