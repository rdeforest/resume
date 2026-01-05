{ env, argv, stdout } =
process    =  require 'process'
{resolve}  =  require 'path'
fs         =  require 'fs'

log        = (require 'debug') 'regen'

envroot    = env.ENVROOT or resolve __dirname, '..'
lib        = (mod) -> require resolve envroot, 'lib', mod

Project    =  lib 'project'
Throbber   =  lib 'throbber'
{ echo }   = (lib 'util') process.stdout
{formats}  = (lib 'formats')

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
      # Generate HTML via Project
      project.refresh()

      # Generate other formats
      resumé = project.data()
      publicDir = resolve envroot, 'public'

      # Build array of promises for all format conversions
      promises = for formatName, format of formats when formatName isnt 'html'
        do (formatName, format) ->
          ext = format.extension or formatName
          outputPath = resolve publicDir, "#{config.project}.#{ext}"

          Promise.resolve format.converter resumé
            .then (output) ->
              # Handle different output types
              content = switch
                when Buffer.isBuffer output then output
                when typeof output is 'string' then output
                else JSON.stringify output, null, 2

              fs.writeFileSync outputPath, content
              console.log "  Generated #{formatName}: #{outputPath}"
            .catch (e) ->
              console.error "  Failed to generate #{formatName}: #{e.message}"

      # Wait for all formats to complete
      Promise.all promises
        .then ->
          echo "#{throbber.throb()}\r"
          setTimeout refresh, watchSleep if watch
        .catch (e) ->
          echo "\n---\n#{e.toString()}\n"
          watchSleep = errorSleep
          echo "#{throbber.throb()}\r"
          setTimeout refresh, watchSleep if watch

    catch e
      echo "\n---\n#{e.toString()}\n"
      watchSleep = errorSleep
      echo "#{throbber.throb()}\r"
      setTimeout refresh, watchSleep if watch

  else
    echo "#{throbber.throb()}\r"
    setTimeout refresh, watchSleep if watch

refresh()

