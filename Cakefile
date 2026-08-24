fs      = require 'fs'
path    = require 'path'
util    = require 'util'

debug   = require 'debug'

log     = debug 'Cakefile'

Task    = (require './lib/task') {task, option}

option '-w', '--watch',   'Restart/recompile on file change'
option '-d', '--debug',   'Turn on default debugging'
option '-n', '--dry-run', 'Print what would happen without doing it'

taskDir = path.resolve __dirname, 'tasks'
log "Loading tasks from #{taskDir}"

fs.readdirSync taskDir
  .filter  (name) -> name.endsWith '.coffee'
  .forEach (name) ->
    taskPath = path.resolve taskDir, name
    log "Loading task #{name} from path #{taskPath}"
    (require taskPath) Task
