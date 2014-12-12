from strutils import toHex, replace

proc escapedStringLen(origLen: int): int =
  # 1.1x original size
  return origLen + origLen div 10

proc escapeJson*(str: string): string =
  result = str
  result = result.replace("\\", "\\\\")
  result = result.replace("\"", "\\\"")
  result = "\"" & result & "\""

proc escapeHtml*(str: string): string =
  result = newStringOfCap(escapedStringLen(str.len))
  for c in str:
    case c
    of {'<', '>', '"', '\'', '`', '&'}:
      result.add("&#" & $int(c) & ";")
    else:
      result.add(c)

proc escapeUrlComponent*(str: string): string =
  result = newStringOfCap(escapedStringLen(str.len))
  for c in str:
    case c
    of {'a'..'z',
        'A'..'Z',
        '0'..'9',
        '-', '_',
        ',', '!',
        '~', '*',
        '(', ')'}:
      result.add(c)
    else:
      result.add("%" & toHex(int(c), 2))

proc mkstemp(templ: cstring): cint {.cdecl, header: "stdio.h", importc.}

proc mkTemp*(templ: string = "/tmp/pygments_comm_"): tuple[fd: File, name: string] =
  var filePath: cstring = templ & "XXXXXX"
  let fh = mkstemp(filePath)
  if fh == -1:
    raise newException(Exception, "Failed create temporary file")

  if not open(result.fd, fh, fmReadWrite):
    raise newException(Exception, "Failed top open FileHandle as a file")

  result.name = $filePath

