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

  <div class="search-area subsection">
    <script>
    (function() {
      var cx = '013569886790416879332:nievnee8p10';
      var gcse = document.createElement('script');
      gcse.type = 'text/javascript';
      gcse.async = true;
      gcse.src = (document.location.protocol == 'https:' ? 'https:' : 'http:') +
          '//www.google.com/cse/cse.js?cx=' + cx;
      var s = document.getElementsByTagName('script')[0];
      s.parentNode.insertBefore(gcse, s);
    })();
    </script>
    <gcse:search></gcse:search>
  </div>

  """)

