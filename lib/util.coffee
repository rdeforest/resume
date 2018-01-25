module.exports =
makeVerbs = (stdout) ->
  cat: (files) ->
    files
      .map (f) ->
        for retry in [3..1]
          try
            return fs.readFileSync f
      .join ''

  echo: (s) -> stdout.write s

Object.assign makeVerbs,
  # wait... isn't this just require.main?
  topModule: (childModule) ->
    if childModule.parent
      topModule childModule.parent
    else
      childModule

  modules: modules = (seen, module) ->
    if arguments.length is 1
      [module, seen] = [seen, []]
    else
      return [] if module.id in seen

    seen.push module.id

    module
      .children
      .concat (module.children.map modules.bind null, seen)...
      .filter ({filename}) -> -1 is filename.indexOf 'node_modules'

  sourceFiles: sourceFiles = (module) ->
    modules module
      .map ({filename}) -> filename

