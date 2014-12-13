import parse_snippets
import re
import json

# matches all tags in well-formed html
let htmlTags = re"""<\/?(?:[^>"']|'[^']*+'|"[^"]*+")*+>"""
let longWhitespace = re"""\s{2,}"""

proc stripHtml(str: string): string =
  result = str.replace(htmlTags)
  result = result.replace(longWhitespace)

proc `%`(snip: Snippet): PJsonNode =
  result = %{
      "id" : %snip.id,
      "title" : %snip.title,
      "author" : %snip.author,
      "code" : %snip.code.stripHtml(),
      "desc" : %snip.description.stripHtml(),
      "tags" : newJArray(),
  }

  for tag in snip.tags:
    result["tags"].add(%tag)


proc renderDocumentIndex*(data: seq[Snippet]): string =
  var resultJson = newJArray()
  for snip in data:
    resultJson.add(%snip)

  return $resultJson
