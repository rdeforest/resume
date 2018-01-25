fs            = require 'fs'
child_process = require 'child_process'

debug         = (require 'debug') 'watch'

{ sourceFiles
  topModule
  modules }   = require './util'

module.exports =
watcher =
  (modulePath) ->
    debug = (require 'debug') "watcher:#{modulePath}"
    debug 'creating watcher'

    start = exported = watchers = subModule = null

    unload = (startingModule) ->
      unloaded = undefined
      _unload = (module) ->
        debug "unloading #{module.id}"
        unloaded ?= []

        for child in modules topModule module when child?.id not in unloaded
          unloaded.push child.id
          _unload child

        require.cache[module.id] = undefined
      _unload startingModule
      unloaded = undefined

    restart = ->
      debug "restarting"
      Promise
        .resolve (exported?.stop() if 'function' is typeof exported.stop)
        .then ->
          debug "stopped"
          watchers.map (w) -> w.close()
          unload subModule
          debug "unloaded"
          start()

    start = (args...) ->
      debug "loading"
      exported  = require modulePath
      subModule = module.children.find (mod) -> mod.exports is exported
      files     = sourceFiles subModule

      watchers = files
        .map (file) ->
          debug "watching #{file}"
          fs.watch file
            .on 'change', -> restart()

      debug "starting"
      exported args...

    return start
