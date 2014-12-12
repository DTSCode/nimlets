import tables
import parse_snippets
import sets
import strutils
import math
import templates.search_index

type
  WordType {.pure.} = enum
    Title, Author, Code, Description

proc merge[T](a, b: CountTable[T]): CountTable[T] =
  result = initCountTable[T]()
  for v, i in a:
    result.inc(v, i)
  for v, i in b:
    result.inc(v, i)

type
  SnippetStats = object
    snippet: Snippet
    wordFreqs: array[WordType, CountTable[string]]

proc getStopwords(): TSet[string] =
  let text = "./stop_words".readFile()
  result = toSet(text.split('\l'))

let stopWords = getStopwords()

iterator tokenize(input: string): string =
  for word in input.split({' ', '.', '\l', '\r', '\t'}):
    if word notin stopWords:
      yield word

proc wordFreq(input: string): CountTable[string] =
  result = initCountTable[string]()
  for word in tokenize(input):
    result.inc(normalize(word))

proc generateFrequencies(self: Snippet): SnippetStats =
  result.snippet = self
  result.wordFreqs[WordType.Title]       = wordFreq(self.title)
  result.wordFreqs[WordType.Author]      = wordFreq(self.author)
  result.wordFreqs[WordType.Code]        = wordFreq(self.rawSnippet.code)
  result.wordFreqs[WordType.Description] = wordFreq(self.rawSnippet.description)

proc getRelevence(globalStats: CountTable[string], word: string, count: int): float =
  return globalStats[word] / count

proc getSnippetRelevence(globalStats: CountTable[string],
                         body: SnippetStats,
                         cutoff: float = 0.01): Table[string, float] =
  result = initTable[string, float]()

  for word, count in body.wordFreqs[WordType.Code].merge(
                     body.wordFreqs[WordType.Description]):
    result[word] = globalStats.getRelevence(word, count)


proc analyze(data: seq[SnippetStats]): Table[string, Table[int, float]] =
  # Returns { token : { snippet_id : relevence } }

  result = initTable[string, Table[int, float]]()

  var totalFreq = initCountTable[string]()
  for snippet in data:
    for key, table in snippet.wordFreqs:
      if key in {WordType.Code, WordType.Description}:
        totalFreq = totalFreq.merge(table)

  for snippet in data:
    for term, relevence in totalFreq.getSnippetRelevence(snippet):
      if not result.hasKey(term):
        result[term] = initTable[int, float]()

      result.mget(term)[snippet.snippet.numId] = relevence

proc analyzeAndRender*(data: seq[Snippet]): string =
  # returns { (token : { (snippet_name : relevence)* })* } in json format
  var snippetData: seq[SnippetStats] = @[]

  for snip in data:
    snippetData.add(generateFrequencies(snip))

  var numToId = initTable[int, string]()
  for snip in data:
    numToId[snip.numId] = snip.id

  return renderSearchIndex(analyze(snippetData), numToId)
