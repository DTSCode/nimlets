import lib/discount.nim
import unsigned

proc render*(input: string, flags: uint32 = mkdAutoLink or mkdTabStop): string =
  ## Renders the markdown in `input` to html
  ##
  ## Error handling is terrible, don't make syntax errors!
  var cinput = cstring(input)
  var inputSize = cint(input.len)

  var target: ptr cstring = create(type(cstring))
  var document = mkd_string(cinput, inputSize, flags)
  doAssert document != nil
  doAssert mkd_compile(document, flags) == 1
  var targetSize = mkd_document(document, target)

  doAssert targetSize != -1

  result = $target[]

  mkd_cleanup(document)
