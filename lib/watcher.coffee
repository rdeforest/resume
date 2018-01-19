fs = require 'fs'

{sourceFiles, modules} = require './util'

# TODO: run the module in a child process and restart it as needed
module.exports =
watcher =
  (modulePath) ->
    debug = (require 'debug') "watcher:#{modulePath}"
    debug 'creating watcher'

    start = exported = watchers = subModule = null

    unloaded = undefined
    unload = (module) ->
      debug "unloading #{module.id}"
      unloaded ?= []

      for child in modules module
        if child.id in unloaded
          throw new Error "Unload loop?"

        unloaded.push child.id
        unload child

      require.cache[module.id] = undefined
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
