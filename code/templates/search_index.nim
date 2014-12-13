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

proc renderIdToName(idToName: Table[string, string]): string =
  result = "{"
  var delimiter = ""

  for id, name in idToName:
    result.add("$1$2:$3" % [delimiter,
                            escapeJson(id),
                            escapeJson(name)])
    delimiter = ","

  result.add("}")


proc renderSearchIndex(data: Table[string, Table[string, float]]): string =
  result = "{"
  var delimiter = ""

  for word, value in data:
    result.add("$1$2:$3" % [delimiter,
                            escapeJson(word),
                            renderRelevences(value)])
    delimiter = ",\l"

  result.add("}")

proc renderIndex*(data: Table[string, Table[string, float]],
                  idToName: Table[string, string]): string =
  return "{\"index\":$1,\"idToName\":$2}" % [renderSearchIndex(data),
                                             renderIdToName(idToName)]
