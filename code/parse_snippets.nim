from strutils import splitLines, `%`, strip
from re import `=~`, re
import pygments
import yaml
from markdown import nil

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
    rawSnippet*: ref Snippet

proc parseMetadata(header: string): Snippet =
  let parsedHeader = yaml.load(header)[0]

  result.title = parsedHeader.title.get(string)
  result.author = parsedHeader.author.get(string)
  result.tags = @[]

  for tag in parsedHeader.tags:
    result.tags.add(tag.get(string))

proc parseSnippet*(text: string): Snippet =
  # Parses the snippet, but it blocks. Make sure to
  # run multiple in seperate threads
  let (metadata, rest) = splitHeader(text)
  let (description, code) = splitHeader(rest)

  result = parseMetadata(metadata)
  result.rawSnippet = (ref Snippet)( code : code, description : description )

  result.code = renderCode(code, "nimrod")
  result.description = markdown.render(description)
