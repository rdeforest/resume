http   = require 'http'
debug  = require('debug') 'resume:server'
app    = require '../app'

Port = require '../lib/port'

module.exports = (Task) ->
  new Task
    run:
      description: 'Run an HTTP service'

      options:
        host: 'localhost'
        port: defaults: [env: 'PORT', '3000']

      start: (options) ->
        debug 'Starting server...'
        {host, port} = options
        debug "options: %O", options
        port = new Port port
        app.set 'port', port.toString()

        server = http.createServer app

        onError = (error) ->
          debug 'there was an error'
          throw error unless error.syscall is 'listen'

          msg =
          switch error.code
            when 'EACCES'     then 'requires elevated privileges'
            when 'EADDRINUSE' then 'is already in use'
            else throw error

          console.error port.name + ' ' + msg
          process.exit 1
          return

        onListening = ->
          addr = server.address()
          debug "Listening on #{port.name.toLowerCase()} #{addr.port ? addr}"
          return

        server.listen port.toString(), host
              .on 'error',     onError
              .on 'listening', onListening

      stop: ->
        new Promise (resolve, reject) ->
          server.close resolve

