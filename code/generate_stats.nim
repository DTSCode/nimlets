from tables import CountTable, `inc`, initCountTable, pairs
import strutils


proc merge[T](a, b: CountTable[T]): CountTable[T] =
  result = initCountTable[T]()
  for i, v in a:
    result.inc(v, i)
  for i, v in b:
    result.inc(v, i)

type
  SnippetStats* = object
    wordFreq: CountTable[string]

proc wordFreq(input: string): CountTable[string] =
  result = initCountTable[string]()
  for word in input.split({' ', '.', '\l', '\r'}):
    result.inc(normalize(word))

proc generateStats*(title, author, code, desc: string): SnippetStats =
  discard
