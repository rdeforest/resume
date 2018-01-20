fs      = require 'fs'
path    = require 'path'
util    = require 'util'

debug   = require 'debug'

log     = debug 'Cakefile'

Task    = (require './lib/task') {task, option}

option '-w', '--watch', 'Restart/recompile on file change'
option '-d', '--debug', 'Turn on default debugging'

fs.readDirSync taskDir = path.resolve __dirname, 'tasks'
    .filter  (name) -> not name.beginsWith '.'
    .forEach (name) ->
      taskModule = require path.resolve taskDir, name
      taskModule {task, option}

#run:  'lib/server': 'Start Express'
#gen:  'lib/regen':  'Generate static content'
#test: 'test/all':   'Run test suite'
