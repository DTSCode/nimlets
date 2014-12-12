import templates.base
import util
from strutils import `%`

proc renderIndex*(): string =
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
    <form class="unit whole" onsubmit="return false;">
      <input name="q"
             type="search"
             autofocus
             autocomplete="off"
             placeholder="Search"
             class="search">
      <input type="button" onClick="performSearch()" style="display: none;">
    </form>
  </div>

  <div class="search-results" style="display: none;">
    <div class="grid">
      <h2 class="unit whole search-results-title">Search Results</h2>
    </div>
    <div class="search-results-body"></div>
  </div>
  """)

