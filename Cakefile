fs      = require 'fs'
path    = require 'path'
util    = require 'util'

debug   = require 'debug'

log     = debug 'Cakefile'

Task    = (require './lib/task') {task, option}

option '-w', '--watch', 'Restart/recompile on file change'
option '-d', '--debug', 'Turn on default debugging'

taskDir = path.resolve __dirname, 'tasks'
log "Loading tasks from #{taskDir}"

fs.readdirSync taskDir = taskDir
    .filter  (name) ->
      return name is 'run.coffee'
      not name.startsWith '.'
      
    .forEach (name) ->
      taskPath = path.resolve taskDir, name
      log "Loading task #{name} from path #{taskPath}"
      (require taskPath) Task
