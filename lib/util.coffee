fs = require 'fs'

# Watch mode can catch a source file mid-rewrite, so a read gets a couple more
# chances before the failure propagates.
read = (file, attempts = 3) ->
  for attempt in [1..attempts]
    try
      return fs.readFileSync file, 'utf8'
    catch e
      throw e if attempt is attempts
  return

module.exports =
makeVerbs = (stdout) ->
  cat: (files) -> files.map(read).join ''

  echo: (s) -> stdout.write s

Object.assign makeVerbs,
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

