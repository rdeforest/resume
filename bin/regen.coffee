#!/usr/bin/env coffee

{ env, argv, stdout } =
process    = require 'process'

{resolve}  = require 'path'

envroot    = env.ENVROOT or resolve __dirname, '..'
lib        = (mod) -> require resolve envroot, 'lib', mod

Project    = lib 'project'
Throbber   = lib 'throbber'

configFile = resolve envroot, 'config.yaml'

console.log {envroot, configFile}

{ watch: watchFlag = '-w' in argv

  project  = 'resume'
  theme    = 'default'
  watchSleepMs = 500
  errorSleepMs = 5000

  dataDir, projectDir,  themeDir
  data,    destination, template, css
} = (config = new (require '../lib/config') {envroot})

config
  .load configFile
  ._  dataDir:    dataDir    = -> resolve envroot,    'data',
      projectDir: projectDir = -> resolve dataDir,    'projects', project
      themeDir:   themeDir   = -> resolve dataDir,    'themes',   theme

      destination:             -> resolve env.HOME,   'Desktop',   project + '.html'
      data:                    -> resolve projectDir, 'data.yaml'
      template:                -> resolve themeDir,   'main.pug'
      css:                     -> resolve themeDir,   'style',     'style.css'

project  = new Project {destination, data, template, css}

throbber = Throbber.line

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

  if watchFlag
    setTimeout refresh, watchSleep

refresh()

