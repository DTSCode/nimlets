import util
import tables
import strutils

proc renderNameIds(numIdToName: Table[int, string]): string = 
  result = "{"
  var delimiter = ""
  for numId, id in numIdToName:
    result.add("$1$2:$3" % [delimiter,
                            $numId,
                            escape(id)])
    delimiter = ","

  result.add("}")

proc renderRelevences(data: Table[int, float], digits: int = 4): string =
  result = "{"
  var delimiter = ""
  for snippetid, relevence in data:
    result.add("$1$2:$3" % [delimiter,
                            $snippetId,
                            formatFloat(relevence, precision = digits)])
    delimiter = ","

  result.add("}")

proc renderIndex(data: Table[string, Table[int, float]]): string =
  result = "{"
  var delimiter = ""

  for word, value in data:
    result.add("$1$2:$3" % [delimiter,
                            escape(word),
                            renderRelevences(value)])
    delimiter = ",\l"

  result.add("}")


proc renderSearchIndex*(data: Table[string, Table[int, float]],
                        numIdToId: Table[int, string]): string =
  result = "{\"numToId\":$1,\"index\":$2}" % [renderNameIds(numIdToId),
                                              renderIndex(data)]
