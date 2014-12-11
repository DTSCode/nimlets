import streams, osproc
from strutils import `%`, join
import os

proc mkstemp(templ: cstring): cint {.cdecl, header: "stdio.h", importc.}

type CFile {.importc: "FILE", header: "<stdio.h>",
final, incompletestruct.} = object

proc mkTemp(templ: string = "/tmp/pygments_comm_"): tuple[fd: File, name: string] =
  var filePath: cstring = templ & "XXXXXX"
  let fh = mkstemp(filePath)
  if fh == -1:
    raise newException(Exception, "Failed create temporary file")

  if not open(result.fd, fh, fmReadWrite):
    raise newException(Exception, "Failed top open FileHandle as a file")

  result.name = $filePath

proc renderCode*(code, language: string,
                 lineNums: bool = false, lineNumBase: string = "code"): string =
  let codeFile = mkTemp()
  codeFile.fd.close()
  codeFile.name.writeFile(code)
  finally:
    removeFile(codeFile.name)

  var args = @[
    "-l", language,
    "-f", "html",
    "-P", "cssclass=code",
    codeFile.name,
  ].join(" ")

  if lineNums:
    args.add(" " & @[
      "-P", "linenospecial=10",
      "-P", "linenos=table",
      "-P", "lineanchors=snip",
      "-P", "anchorlinenos=True",
    ].join(" "))

  let processOutput = execCmdEx("pygmentize " & args)

  result = processOutput.output

  if processOutput.exitCode != 0:
    raise newException(Exception, "failed to execute pygmentize (return $1):\n$2" %
        [$processOutput.exitCode, processOutput.output])
