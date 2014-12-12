import streams, osproc
from strutils import `%`, join
import os
from util import mkTemp

proc renderCode*(code, language: string,
                 lineNums: bool = false, lineNumBase: string = "code"): string =
  let codeFile = mkTemp()
  finally: codeFile.fd.close()
  codeFile.name.writeFile(code)
  finally: removeFile(codeFile.name)

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
