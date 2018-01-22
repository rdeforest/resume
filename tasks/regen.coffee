{ env, argv, stdout } =
process    =  require 'process'
{resolve}  =  require 'path'

log        = (require 'debug') 'regen'

envroot    = env.ENVROOT or resolve __dirname, '..'
lib        = (mod) -> require resolve envroot, 'lib', mod

Project    =  lib 'project'
Throbber   =  lib 'throbber'
{ echo }   = (lib 'util') process.stdout

configFile = resolve envroot, 'config.yaml'


log JSON.stringify {envroot, configFile}

configDefaults =
  project      : 'resume'
  theme        : 'default'

  watch        : '-w' in argv
  watchSleepMs :    500
  errorSleepMs :  10000
  throbber     : 'spinner'

{ project, theme
  watch,   watchSleepMs, errorSleepMs, throbber
  dataDir, projectDir,   themeDir
  data,    destination,  template
} =
(config = new (require '../lib/config') config)
  .load configFile
  ._
    dataDir:     -> resolve envroot,           'data'
    projectDir:  -> resolve config.dataDir,    'projects', config.project
    themeDir:    -> resolve config.dataDir,    'themes',   config.theme

    data:        -> resolve config.projectDir,             config.project + '.yaml'
    template:    -> resolve config.themeDir,   'main.pug'
    destination: -> resolve envroot,           'public',   config.project + '.html'

project  = new Project {destination, data, template}
throbber = new Throbber config.throbber

refresh = ->
  {watchSleep, errorSleep} = config

  if project.changed()
    console.log "#{(new Date).toLocaleString()}: regenerating"

    try
      project.refresh()

    catch e
      echo "\n---\n#{e.toString()}\n"
      watchSleep = errorSleep

  echo "#{throbber.throb()}\r"

  if watch
    setTimeout refresh, watchSleep

refresh()

