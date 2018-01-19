module.exports = (stdout) ->
  cat: (files) ->
    files
      .map (f) ->
        for retry in [3..1]
          try
            return fs.readFileSync f
      .join ''

  echo: (s) -> stdout.write s
  modules: modules = (seen, module) ->
    if arguments.length is 1
      module = seen
      seen = []
    else
      return [] if module in seen

    seen.push module
    [module].concat module.children.map(modules.bind null, seen)...

  sourceFiles: sourceFiles = (module) ->
    modules module
      .filter ({filename}) -> -1 is filename.indexOf 'node_modules'
      .map ({filename}) -> filename

