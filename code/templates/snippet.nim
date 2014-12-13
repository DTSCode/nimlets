from strutils import `%`, replace
import util
from parse_snippets import Snippet
import templates.base

proc renderTags(tags: seq[string]): string =
  result = ""
  for tag in tags:
    result.add("""
      <a class="snippet-tag" href="/?q=%5B$1%5D">$2</a>""" % [
        escapeUrlComponent(tag),
        escapeHtml(tag),
    ])

proc renderSnippet(snippet: Snippet): string =
  return """
  <div class="snippet-header">
    <div class="grid">
      <h1 class="unit whole snippet-name">
        $#
      <a class="icon-download snippet-download" href="data:application/octet-stream,$#" filename="$#"></a>
      </h1>
    </div>
    <div class="grid">
      <div class="unit half snippet-author">$#</div>
      <div class="unit half snippet-tags">
      $#
      </div>
    </div>
  </div>
  <div class="grid">
    <div class="unit whole snippet-description subsection">$#</div>
  </div>
  <div class="grid">
    <div class="unit whole snippet-code subsection">$#</div>
  </div>
  """ % [
    escapeHtml(snippet.title),
    escapeUrlComponent(snippet.code),
    escapeUrlComponent(snippet.id.replace("-", "_")),
    escapeHtml(snippet.author),
    renderTags(snippet.tags),
    snippet.description,
    snippet.code,
  ]

proc renderSnippetPage*(snippet: Snippet): string =
  return renderBase(inner = renderSnippet(snippet), title = snippet.title)

