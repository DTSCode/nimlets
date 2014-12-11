import util
import tables
import strutils

proc renderRelevences(data: Table[string, float], digits: int = 4): string =
  result = "{"
  var delimiter = ""
  for snippetName, relevence in data:
    result.add("$1$2:$3" % [delimiter,
                            escape(snippetName),
                            formatFloat(relevence, precision = digits)])
    delimiter = ","

  result.add("}")


proc renderSearchIndex*(data: Table[string, Table[string, float]]): string =
  result = "{"
  var delimiter = ""

  for word, value in data:
    result.add("$1$2:$3" % [delimiter,
                            escape(word),
                            renderRelevences(value)])
    delimiter = ",\l"

  result.add("}")
