# TODO: run the module in a child process and restart it as needed
module.exports =
watcher =
  (modulePath) ->
    debug = (require 'debug') "watcher:#{modulePath}"

    exported = watchers = restart = subModule = null

    unload = (module) ->
      debug "unloading #{module}"
      children.map (child) -> unload child
      require.cache[module.id] = undefined

    start = ->
      debug "loading"
      exported = require modulePath
      subModule = module.children.find (mod) -> mod.exports is exported
      files = sourceFiles subModule

      watchers = files.map (file) ->
        fs.watch file
          .on 'change', -> restart()

      return exported

    restart = ->
      Promise
        .resolve (exported.stop() if 'function' is typeof exported.stop)
        .then ->
          watchers.map (w) -> w.close()
          unload subModule
          start()

