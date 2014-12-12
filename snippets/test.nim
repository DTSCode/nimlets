## title: A macro to do addition on testing123s
## id: add-123s
## author: Foo Bar <foo.bar@acme.com>
## tags:
##     - addition
##     - macro
##     - testing123

## A description written in [discount's markdown dialect](
## http://www.pell.portland.or.us/~orc/Code/discount/)
## It supports images too!
##
## > Some guy said some stuff
##
## ## Awesome Cat!
## ![cat](http://i.imgur.com/Sibekhc.jpg)

import macros

macro addition(): expr =
  return parseExpr("1 + 2 # testing123")

echo addition()
