{resolve} = require 'path'

Config    = require './config'

envroot   = process.env.ENVROOT or resolve __dirname, '..'

defaults = ->
  project:      'resume'
  theme:        'default'
  watchSleepMs:   500
  errorSleepMs: 10000
  throbber:     'spinner'

# config.yaml carries repo-relative paths; resolve makes them absolute and
# leaves already-absolute values alone, so tasks work from any cwd.
pathKeys = ['dataDir', 'projectDir', 'themeDir', 'data', 'template', 'destination']

load = ->
  config = new Config defaults()

  config.load resolve envroot, 'config.yaml'

  config._
    dataDir:     -> resolve envroot,           'data'
    projectDir:  -> resolve config.dataDir,    'projects'
    themeDir:    -> resolve config.dataDir,    'themes', config.theme
    data:        -> resolve config.projectDir, "#{config.project}.coffee"
    template:    -> resolve config.themeDir,   'main.pug'
    destination: -> resolve envroot, 'public',  "#{config.project}.html"

  config[key] = resolve envroot, config[key] for key in pathKeys

  config

module.exports = load
module.exports.envroot = envroot
