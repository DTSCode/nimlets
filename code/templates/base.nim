import util
from strutils import `%`

let scripts: seq[string] = @[
  "//cdnjs.cloudflare.com/ajax/libs/jquery/2.1.1/jquery.min.js",
  "//cdnjs.cloudflare.com/ajax/libs/underscore.js/1.7.0/underscore-min.js",
  "//cdnjs.cloudflare.com/ajax/libs/handlebars.js/2.0.0/handlebars.min.js",

  "/javascripts/main.js",
]
let stylesheets: seq[string] = @[
  "//cdnjs.cloudflare.com/ajax/libs/normalize/3.0.1/normalize.min.css",
  "/stylesheets/gridism.css",
  "/stylesheets/syntax-highlight.css",

  "/stylesheets/base.css",
]

proc renderStylesheets(stylesheetPaths: seq[string]): string =
  result = ""
  for stylesheet in stylesheetPaths:
    result.add("""<link rel="stylesheet" href="$1">""" % [stylesheet])
    result.add("\n")

proc renderScripts(scriptPaths: seq[string]): string =
  result = ""
  for script in scriptPaths:
    result.add("""<script src="$1"></script>""" % [script])
    result.add("\n")

proc renderBase*(title, inner: string): string =
  return """
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>$1</title>
    <!-- begin css -->
    $3
    <!-- end css -->
  </head>
  <body>
    $2
    <!-- begin js -->
    $4
    <!-- end js -->
  </body>
</html>
  """ % [
    escapeHtml(title),
    inner,
    renderStylesheets(stylesheets),
    renderScripts(scripts),
  ]
