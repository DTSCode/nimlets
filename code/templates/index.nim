import templates.base
import util
from strutils import `%`

proc renderHome*(): string =
  renderBase(title = "Nimlets - Nim Code Examples", inner = """
  <div class="grid">
    <h1 class="header unit whole">
      Nimlets
    </h1>
  </div>
  <div class="grid">
    <h2 class="subtitle unit whole">
      Nim code examples
    </h2>
  </div>

  <div class="grid">
    <div class="unit whole" id="search-area">
      <input id="search-query"
             type="search"
             autofocus
             autocomplete="off"
             placeholder="Search"
             class="search">
    </div>
  </div>

  <div class="search-results" style="display: none;">
    <div class="grid">
      <h2 class="unit whole search-results-title">Search Results</h2>
    </div>
    <div class="search-results-body"></div>
  </div>

  <script>window.searchPage = true;</script>
  """)

