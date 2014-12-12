import util
import tables
import strutils

proc renderRelevences(data: Table[string, float], digits: int = 4): string =
  result = "["
  var delimiter = ""
  for snippetid, relevence in data:
    result.add("$1{\"doc\":$2,\"rel\":$3}" % [delimiter,
                                             escapeJson(snippetId),
                                             formatFloat(relevence,
                                               precision = digits,
                                               format = ffScientific)])
    delimiter = ","

  result.add("]")

proc renderIndex*(data: Table[string, Table[string, float]]): string =
  result = "{"
  var delimiter = ""

  for word, value in data:
    result.add("$1$2:$3" % [delimiter,
                            escapeJson(word),
                            renderRelevences(value)])
    delimiter = ",\l"

  result.add("}")
