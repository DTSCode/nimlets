import streams, osproc


proc readAll(stream: Stream): string =
  result = ""
  while not stream.atEnd:
    result.add(stream.readChar())


proc renderCode*(code, language: string,
                 lineNums: bool = false, lineNumBase: string = "code"): string =
  var args = @[
    "-l", language,
    "-f", "html",
    "-P", "cssclass=code",
  ]

  if lineNums:
    args.add(@[
      "-P", "linenospecial=10",
      "-P", "linenos=table",
      "-P", "lineanchors=snip",
      "-P", "anchorlinenos=True",
    ])

  let process = startProcess("pygmentize", args = args, options = { poUsePath })
  process.inputStream.write(code)
  process.inputStream.flush()
  process.inputStream.close()

  result = readAll(process.outputStream)
  process.close()
  if process.peekExitCode != 0:
    raise newException(Exception, "failed to execute pygmentize:\n" & result)
