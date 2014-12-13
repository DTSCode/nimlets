import templates.base
import util
import parse_snippets
from strutils import `%`

proc renderSnippet(snip: Snippet): string =
  return """
    <div class="grid">
      <div class="unit whole">
        <a href="/$1.html">$2</a>
      </div>
    </div>""" % [snip.id, snip.title]

proc renderSnippets(snippets: seq[Snippet]): string =
  result = ""
  for snip in snippets:
    result.add(renderSnippet(snip))

proc renderSitemap*(snippets: seq[Snippet]): string =
  renderBase(title = "Nimlets Sitemap", inner = """
  <div class="grid">
    <div class="unit whole">
      <h1>Sitemap</h1>
    </div>
  </div>
  <div class="sitemap subsection">
    <div class="grid">
      <div class="unit whole">
        <a href="/">Main Page</a>
      </div>
    </div>
    $1
  </div>
  """ % [renderSnippets(snippets)])

