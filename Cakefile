{sourceFiles} = require './lib/util'
watcher       = require './lib/watcher'
debug         = (require 'debug') 'Cakefile'

tasks = (info...) ->
  while info.length
    [nameAndDesc, fn, info...] = info

    for name, desc of nameAndDesc
      debug "Adding task #{name}: #{desc}"
      task name, desc, fn

option '-w', '--watch', 'Restart/recompile on file change'
option '-d', '--debug', 'Turn on default debugging'

maybeWatch = (modulePath) ->
  (options) ->
    debug "Task #{modulePath} invoked"

    ((if options.watch then watcher else require) modulePath) options

tasks
  run:  'Start Express',             maybeWatch 'lib/server'
  gen:  'Regenerate static content', maybeWatch 'lib/regen'
  test: 'Run test suite',            maybeWatch 'test/all'

