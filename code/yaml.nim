import lib.libyaml
from tables import Table, initTable, `[]`, `[]=`, pairs, `==`
from strutils import parseInt, parseFloat
from hashes import hash, THash, `!&`, `!$`

type
  YamlObjKind {.pure.} = enum
    Seq
    Map
    String
    Null
    Bool
    Int
    Float
    Document
  YamlObj* = ref object
    case kind: YamlObjKind
    of YamlObjKind.Map:
      mapVal: Table[YamlObj, YamlObj]
    of YamlObjKind.Seq:
      seqVal: seq[YamlObj]
    of YamlObjKind.String:
      strVal: string
    of YamlObjKind.Bool:
      boolVal: bool
    of YamlObjKind.Int:
      intVal: int
    of YamlObjKind.Float:
      floatVal: float64
    of YamlObjKind.Null:
      nil
    of YamlObjKind.Document:
      nil
  YamlDoc* = YamlObj

# hash & == {{{
proc hash*(self: YamlObj): THash =
  result = 0
  result = result !& ord(self.kind)
  case self.kind
  of YamlObjKind.Map:
    for k, v in self.mapVal:
      result = result !& hash(k)
      result = result !& hash(v)
  of YamlObjKind.Seq:
    for v in self.seqVal:
      result = result !& hash(v)
  of YamlObjKind.String:
    result = result !& hash(self.strVal)
  of YamlObjKind.Bool:
    result = result !& ord(self.boolVal)
  of YamlObjKind.Int:
    result = result !& hash(self.intVal)
  of YamlObjKind.Float:
    result = result !& hash(self.floatVal)
  of YamlObjKind.Null, YamlObjKind.Document:
    discard

proc `==`*(a, b: YamlObj): bool =
  if a.kind != b.kind: return false
  case a.kind
  of YamlObjKind.Map:
    if a.mapVal != b.mapVal: return false
  of YamlObjKind.Seq:
    if a.seqVal != b.seqVal: return false
  of YamlObjKind.String:
    if a.strVal != b.strVal: return false
  of YamlObjKind.Bool:
    if a.boolVal != b.boolVal: return false
  of YamlObjKind.Int:
    if a.intVal != b.intVal: return false
  of YamlObjKind.Float:
    if a.floatVal != b.floatVal: return false
  of YamlObjKind.Null, YamlObjKind.Document:
    discard
  return true
# }}}

template success(test: expr): stmt =
  if test != 1: raise newException(Exception, "failed to execute")

# `load()` Internals {{{
type
  LoadContext = ref object
    parser: yaml_parser_t
    anchors: Table[string, YamlObj]
    gen: iterator(): yaml_event_t {.closure.}

proc copyEvent(self: yaml_event_t): tuple[typ: yaml_event_type_t, anchor: string] =
  # not for general-purpose use
  if self.data.scalar.anchor == nil:
    return
  return (self.typ, $self.data.scalar.anchor)

proc handleAnchors(self: LoadContext,
                   event: tuple[typ: yaml_event_type_t, anchor: string],
                   result: YamlObj) =
  if event.typ in { YAML_SCALAR_EVENT,
                    YAML_SEQUENCE_START_EVENT,
                    YAML_MAPPING_START_EVENT }:
    # first element in each branch, so is equvilent for all three
    let anchor = event.anchor

    if anchor != nil:
      self.anchors[anchor] = result

proc events(self: LoadContext): iterator(): yaml_event_t =
  # returned events must be copied before this run again
  return iterator(): yaml_event_t =
    var event: yaml_event_t
    while true:
      if yaml_parser_parse(addr self.parser, addr event) != 1:
        raise newException(Exception, "Malformed input: " & $self.parser.error)

      if event.typ == YAML_NO_EVENT:
        break

      yield event

      yaml_event_delete(addr event)

var recognize: array[yaml_event_type_t, proc(self: LoadContext, event: yaml_event_t): YamlObj]

recognize[YAML_DOCUMENT_START_EVENT] = proc(self: LoadContext, event: yaml_event_t): YamlObj =
  let next = self.gen()
  result = recognize[next.typ](self, next)
  let endDoc = self.gen()
  assert(endDoc.typ == YAML_DOCUMENT_END_EVENT, "Document must only have one thing inside")


recognize[YAML_ALIAS_EVENT] = proc(self: LoadContext, event: yaml_event_t): YamlObj =
  return self.anchors[$event.data.alias.anchor]


recognize[YAML_SCALAR_EVENT] = proc(self: LoadContext, event: yaml_event_t): YamlObj =
  var tag: string
  if event.data.scalar.tag != nil:
    tag = $event.data.scalar.tag

  case tag
  of YAML_NULL_TAG: return YamlObj(kind : YamlObjKind.Null)
  of YAML_BOOL_TAG:
    result = YamlObj(kind : YamlObjKind.Bool)
    if event.data.scalar.value == "true":
      result.boolVal = true
    elif event.data.scalar.value == "false":
      result.boolVal = false
    else:
      assert(false, "Unknown boolean value " & $event.data.scalar.value)
  of YAML_INT_TAG:
    return YamlObj(kind : YamlObjKind.Int, intVal : parseInt($event.data.scalar.value))
  of YAML_FLOAT_TAG:
    return YamlObj(kind : YamlObjKind.Float, floatVal : parseFloat($event.data.scalar.value))
  else:  # unknown or string, treat as string
    return YamlObj(kind : YamlObjKind.String, strVal : $event.data.scalar.value)


recognize[YAML_SEQUENCE_START_EVENT] = proc(self: LoadContext, event: yaml_event_t): YamlObj =
  let initialEvent = copyEvent event

  result = YamlObj(kind : YamlObjKind.Seq, seqVal : @[])

  var event = event
  while true:
    event = self.gen()
    if event.typ == YAML_SEQUENCE_END_EVENT: break
    result.seqVal.add(recognize[event.typ](self, event))

  self.handleAnchors(initialEvent, result)


recognize[YAML_MAPPING_START_EVENT] = proc(self: LoadContext, event: yaml_event_t): YamlObj =
  let initialEvent = copyEvent event

  result = YamlObj(kind : YamlObjKind.Map, mapVal : initTable[YamlObj, YamlObj]())

  while true:
    let keyEvent = self.gen()
    if keyEvent.typ == YAML_MAPPING_END_EVENT: break
    let key = recognize[keyEvent.typ](self, keyEvent)

    let valEvent = self.gen()
    let val = recognize[valEvent.typ](self, valEvent)

    result.mapVal[key] = val

  self.handleAnchors(initialEvent, result)


recognize[YAML_SEQUENCE_END_EVENT] = proc(self: LoadContext, event: yaml_event_t): YamlObj =
  assert(false, "Sequence end event should never be triggered")


recognize[YAML_MAPPING_END_EVENT] = proc(self: LoadContext, event: yaml_event_t): YamlObj =
  assert(false, "Mapping end event should never be triggered")


recognize[YAML_DOCUMENT_END_EVENT] = proc(self: LoadContext, event: yaml_event_t): YamlObj =
  assert(false, "Document end event should never be triggered")


recognize[YAML_STREAM_END_EVENT] = proc(self: LoadContext, event: yaml_event_t): YamlObj =
  assert(false, "Stream end event should never be triggered")


recognize[YAML_NO_EVENT] = proc(self: LoadContext, event: yaml_event_t): YamlObj =
  discard
# }}}

proc load*(text: string): seq[YamlDoc] =
  ## Parses the sequence of YAML documents in `text`
  var parser: yaml_parser_t
  success yaml_parser_initialize(addr parser)

  var loadCtx = LoadContext(parser  : parser,
                            anchors : initTable[string, YamlObj]() )

  yaml_parser_set_input_string(addr loadCtx.parser, text, csize(text.len))
  yaml_parser_set_encoding(addr loadCtx.parser, YAML_UTF8_ENCODING)
  loadCtx.gen = loadCtx.events()

  result = @[]

  var event = loadCtx.gen()
  assert(event.typ == YAML_STREAM_START_EVENT, "first event must be a YAML_STREAM_START_EVENT")
  while true:
    event = loadCtx.gen()
    if event.typ == YAML_STREAM_END_EVENT: break
    result.add(recognize[event.typ](loadCtx, event))

  yaml_parser_delete(addr loadCtx.parser)

# `$`() Internals {{{
type
  StringifyContext = ref object
    emitter: yaml_emitter_t
    result: string

proc emit(ctx: StringifyContext, event: ptr yaml_event_t) =
  if yaml_emitter_emit(addr ctx.emitter, event) != 1:
    raise newException(Exception, "Failed to emit event: " &
                       $ctx.emitter.problem)

var renderers: array[YamlObjKind, proc(self: YamlObj, ctx: StringifyContext)]

renderers[YamlObjKind.Seq] = proc(self: YamlObj, ctx: StringifyContext) =
  var event = create(yaml_event_t)
  success yaml_sequence_start_event_initialize(event, nil, nil, 1, YAML_ANY_SEQUENCE_STYLE)
  ctx.emit(event)

  for elem in self.seqVal:
    renderers[elem.kind](elem, ctx)

  success yaml_sequence_end_event_initialize(event)
  ctx.emit(event)

  free event


renderers[YamlObjKind.Map] = proc(self: YamlObj, ctx: StringifyContext) =
  var event = create(yaml_event_t)
  success yaml_mapping_start_event_initialize(event, nil, nil, 1, YAML_ANY_MAPPING_STYLE)
  ctx.emit(event)

  for k, v in self.mapVal:
    renderers[k.kind](k, ctx)
    renderers[v.kind](v, ctx)

  success yaml_mapping_end_event_initialize(event)
  ctx.emit(event)

  free event


renderers[YamlObjKind.String] = proc(self: YamlObj, ctx: StringifyContext) =
  var event = create(yaml_event_t)
  success yaml_scalar_event_initialize(event, nil,
                                       YAML_STR_TAG,
                                       self.strVal,
                                       self.strVal.len.cint,
                                       1, 1, YAML_ANY_SCALAR_STYLE)
  ctx.emit(event)
  free event


renderers[YamlObjKind.Null] = proc(self: YamlObj, ctx: StringifyContext) =
  var event = create(yaml_event_t)
  success yaml_scalar_event_initialize(event, nil,
                                       YAML_NULL_TAG,
                                       "null",
                                       "null".len,
                                       1, 1, YAML_ANY_SCALAR_STYLE)
  ctx.emit(event)
  free event


renderers[YamlObjKind.Bool] = proc(self: YamlObj, ctx: StringifyContext) =
  var event = create(yaml_event_t)
  success yaml_scalar_event_initialize(event, nil,
                                       YAML_BOOL_TAG,
                                       $self.boolVal,
                                       ($self.boolVal).len.cint,
                                       1, 1, YAML_ANY_SCALAR_STYLE)
  ctx.emit(event)
  free event


renderers[YamlObjKind.Int] = proc(self: YamlObj, ctx: StringifyContext) =
  var event = create(yaml_event_t)
  success yaml_scalar_event_initialize(event, nil,
                                       YAML_INT_TAG,
                                       $self.intVal,
                                       ($self.intVal).len.cint,
                                       1, 1, YAML_ANY_SCALAR_STYLE)
  ctx.emit(event)
  free event


renderers[YamlObjKind.Float] = proc(self: YamlObj, ctx: StringifyContext) =
  var event = create(yaml_event_t)
  success yaml_scalar_event_initialize(event, nil,
                                       YAML_FLOAT_TAG,
                                       $self.floatVal,
                                       ($self.floatVal).len.cint,
                                       1, 1, YAML_ANY_SCALAR_STYLE)
  ctx.emit(event)
  free event


renderers[YamlObjKind.Document] = proc(self: YamlObj, ctx: StringifyContext) =
  assert(false, "Document should never be used as a Yaml object")

# }}}

proc `$`*(input: seq[YamlDoc],
          indent: int = 2,
          maxWidth: int = 80): string =
  ## Stringifies the sequence of YAML documents
  ##
  ## `indent` - the size of the indentation
  ## `maxWidth` - the level at which it should be
  ##       wrapped, -1 means no wrapping
  var ctx = StringifyContext( result : "" )

  success yaml_emitter_initialize(addr ctx.emitter)

  yaml_emitter_set_output(
    addr ctx.emitter,
    cast[ptr yaml_write_handler_t](
      proc(ctx: ptr StringifyContext, buffer: pointer, size: csize): cint {.nimcall.}=
        var bufferString = newString(size)
        moveMem(cstring(bufferString), buffer, size)
        ctx.result.add(bufferString)
        return 1
    ),
    addr ctx)
  yaml_emitter_set_encoding(addr ctx.emitter, YAML_UTF8_ENCODING)
  yaml_emitter_set_canonical(addr ctx.emitter, 0)
  yaml_emitter_set_indent(addr ctx.emitter, indent.cint)
  yaml_emitter_set_unicode(addr ctx.emitter, 1)

  var event = create(yaml_event_t)

  success yaml_stream_start_event_initialize(event, YAML_UTF8_ENCODING)
  ctx.emit(event)

  for doc in input:
    success yaml_document_start_event_initialize(event, nil, nil, nil, 1)
    ctx.emit(event)

    renderers[doc.kind](doc, ctx)

    success yaml_document_end_event_initialize(event, 1)
    ctx.emit(event)

  success yaml_stream_end_event_initialize(event)
  ctx.emit(event)

  free event

  yaml_emitter_delete(addr ctx.emitter)

  return ctx.result
