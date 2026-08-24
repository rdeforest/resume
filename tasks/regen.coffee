Project        = require '../lib/project'
Throbber       = require '../lib/throbber'
settings       = require '../lib/settings'
{echo}         = (require '../lib/util') process.stdout
{writeFormats} = require '../lib/generate'

log            = (require 'debug') 'regen'

module.exports = (Task) ->
  new Task
    regen:
      description: 'Regenerate every output format from the resumé data'

      start: (options) ->
        config   = settings()
        {data, template, destination, watchSleepMs, errorSleepMs} = config

        log JSON.stringify {data, template, destination}

        project  = new Project {data, template, destination}
        throbber = new Throbber config.throbber
        watch    = Boolean options.watch or config.watch

        again = (sleepMs) ->
          echo "#{throbber.throb()}\r"
          setTimeout regenerate, sleepMs if watch

        failed = (e) ->
          echo "\n---\n#{e.stack ? e}\n"
          again errorSleepMs

        regenerate = ->
          return again watchSleepMs unless project.changed()

          echo "#{(new Date).toLocaleString()}: regenerating\n"

          try
            project.refresh()
            echo "  #{destination}\n"

            writeFormats project.data(), destination
              .then (written) ->
                echo "  #{file}\n" for file in written
                again watchSleepMs
              .catch failed

          catch e
            failed e

        regenerate()
