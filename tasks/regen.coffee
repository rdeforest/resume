{resolve}   = require 'path'
log         = (require 'debug') 'regen'
app         = require '../app'
{ formats } = require '../lib/formats'

module.exports = (Task) ->
  new Task
    regen:
      description: 'Generate static versions of documents'

    options:
      output:
        description: 'Where to put generated files'
        default: resolve config.envroot, 'public'

    start: (options) ->
      {settings: {config}} = app
      log config, options

      publicDir = options.output
      fileName  = config.project

      for ext, format of formats
        filePath = resolve publicDir, fileName + "." + ext

        log "Generating #{filePath}"

