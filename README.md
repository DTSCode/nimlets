Nimlets
=================

http://nimlets.github.io is a site dedicated to demonstrating standalone snippets of Nim code. So-called "Nimlets" are organized by name and tag. 


Building
========

To build the output artifacts simply run "./build" in the root directory. This will install a virtualenv and a number of packages, build some Nim helpers and compile "./snippets/*" to html in a directory called "output".

See ["./code/notes.md"](https://github.com/nimlets/nimlets.github.io/blob/master/code/notes.md) for details on the structure


Testing
=======

To test locally, simply cd into the output directory and run a web server. `python2 -m SimpleHTTPServer` is a good choince since it's simple and probably available.
