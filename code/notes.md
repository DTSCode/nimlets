# Internal Notes

## Dependencies
  - Python 3
    - virtualenv
  - Nim > 2014-12-08
  - Linux or something similar

## Build system
  - `/build` to do the high-level building of everything
  - [Peru][peru_web] is used to deal with dependencies.
    - It also compiles the C libraries into binaries
    - I'm not too attached to it, feel free to replace it with something else and
      send a PR
  - `/code/lib/py-init` to set up the virtualenv

peru_web]: https://github.com/buildinspace/peru

## Implementation

### Syntax highlighting
  - [Pygments](pygments_web) (Python) used for syntax highlighting
  - Not really receptive to switching to a Nim library for this until a
    comparable number of other languages are implemented
  - IPC code is in `code/pygments.nim`
    - Seems to work, sometimes messes up on cleanup
  - Future directions:
    - Daemonize the process, but these are static pages so it doesn't really
      matter.

pygments_web]: http://pygments.org/

### Markdown parsing
  - [Discount][discount_web] used for processing
  - [Better syntax docs are available here][discount_docs]
  - Usage is in `code/markdown.nim`
  - Thin wrapper is in `code/lib/discount.nim`

discount_web]: http://www.pell.portland.or.us/~orc/Code/discount/
discount_docs]: https://h3rald.com/hastyscribe/HastyScribe_UserGuide.htm

### Yaml parsing
  - Uses [libyaml][libyaml_web] for the implementation
  - Rich wrapper has too many features, probably should be make into a package
    - Should also create a lot more unit tests, it's long and complicated
    - Located at `code/yaml.nim`
  - Thin wrapper is at `code/lib/libyaml.nim`

### Search functionality
  - Not yet implemented
  - General idea is
    - index from description, name, code
      - weight = num in doc / num total
      - Lowest weights are useless and eliminated
    - create a json {token : {snippet_name : relevence}}
    - client side
      - Tokenize query
      - Select snippet_name, sum(weight) Where token In tokenize(query)
      - If performance issues arise, two solutions:
        - Web workers
        - Trim the tail end of the results every few steps

### Presentation
  - The "templates" are in `templates/`
  - The css is in `stylesheets/`
  - [gridism][gridism_web] is used for responsiveness, very simple to use
  - Future directions:
    - Proper templating engine (make a new one?)
    - Reminder that something else slipped my mind

gridism_web]: https://github.com/cobyism/gridism

