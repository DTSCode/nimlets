from strutils import toHex
proc escapedStringLen(origLen: int): int =
  # 1.1x original size
  return origLen + origLen div 10

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
