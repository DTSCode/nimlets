import templates.base
import util
from strutils import `%`

proc renderHome*(): string =
  renderBase(title = "Nimlets - Nim Code Examples", inner = """
  <h1 class="title">
    Nimlets
  </h1>
  <h2 class="subtitle">
    Nim code snippets
  </h2>

  <div class="grid">
    <div class="unit whole search-area">
      <input id="search-query"
             class="search-textbox"
             type="search"
             autofocus
             autocomplete="off"
             placeholder="Search"
             class="search">
    </div>
  </div>

  <div class="subsection search-results">
    <div class="search-results-body"></div>
  </div>

  <script>window.searchPage = true;</script>
  """)

