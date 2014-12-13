Nimlets
===
<http://nimlets.github.io> is a site dedicated to demonstrating standalone
snippets of Nim code. So-called "Nimlets" are organized by name and tag.


Submitting a Snippet
---
Add a new file under the `snippets/` directory and send a PR. It might be a
good idea to use another snippet as a template, but snippets essentially
consist of a YAML header with metadata, a description, and the code below all
that.

Building the web site before submission is not required, and might even be
impossible on non-unix OSes.

By submitting a pull request, you licence your code under the MIT licence.


Building
---
To build the output artifacts simply run `build` in the root directory. This
will set up dependencies, compile the snippets to html, and place them in
`output/`.

See [`./code/notes.md`][notes] for details on the structure of the software.

  [notes]: https://github.com/nimlets/nimlets.github.io/blob/master/code/notes.md


Testing
---
To test locally, simply enter the output directory and run a web server.
`python2 -m SimpleHTTPServer` is a good choice since it's simple and probably
available on your system.
