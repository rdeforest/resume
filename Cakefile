debug   = require 'debug'

watcher = require './lib/watcher'

log     = debug 'Cakefile'

option '-w', '--watch', 'Restart/recompile on file change'
option '-d', '--debug', 'Turn on default debugging'

taskDefs =
  run:  'lib/server': 'Start Express'
  gen:  'lib/regen':  'Generate static content'
  test: 'test/all':   'Run test suite'

applyOptions = (modulePath) ->
  (options) ->
    log "Task #{modulePath} invoked"

    if options.debug
      debug.enable '*'
    else
      debug.disable()

    ((if options.watch then watcher else require) modulePath) options

tasks = (info) ->
  for name, detail of info
    for modPath, desc of detail
      log "Adding task #{name}: #{desc}"
      task name, desc, applyOptions modPath

tasks taskDefs
