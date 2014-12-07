from strutils import `%`
import util
from parse_snippets import Snippet
import base

proc renderTags(tags: seq[string]): string =
  result = ""
  for tag in tags:
    result.add("""
      <a class="snippet-tag" href="/tags#t=$1">$2</a>""" % [
        escapeUrlComponent(tag),
        escapeHtml(tag),
    ])

proc renderSnippet(snippet: Snippet): string =
  return """
  <div class=grid>
    <h1 class="unit whole snippet-name">$#</h1>
  </div>
  <div class=grid>
    <div class="unit one-third snippet-author">$#</div>
    <div class="unit two-thirds snippet-tags">
    $#
    </div>
  </div>
  <div class=grid>
    <div class="unit whole snippet-description">$#</div>
  </div>
  <div class=grid>
    <div class="unit whole snippet-code">$#</div>
  </div>
  """ % [
    escapeHtml(snippet.title),
    escapeHtml(snippet.author),
    renderTags(snippet.tags),
    snippet.description,
    snippet.code,
  ]

proc renderSnippetPage*(snippet: Snippet): string =
  return renderBase(inner = renderSnippet(snippet), title = snippet.title)

