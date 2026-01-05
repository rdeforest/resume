http   = require 'http'
debug  = require('debug') 'resume:server'
app    = require '../app'

Port = require '../lib/port'

module.exports = (Task) ->
  new Task
    run:
      description: 'Run an HTTP service'

      options:
        host:       'localhost'
        port:       defaults: [env: 'PORT', '3000']
        background: false

      start: (options) ->
        {host, port, background} = options

        # Daemonize if requested
        if background
          {spawn} = require 'child_process'
          # Remove --background/-b from args to avoid infinite fork
          args = process.argv[1..].filter (arg) ->
            arg not in ['--background', '-b']
          child = spawn process.argv[0], args,
            detached: true
            stdio: 'ignore'
          child.unref()
          console.log "Server daemonized with PID #{child.pid}"
          process.exit 0
          return

        console.log 'Starting server...'
        console.log "Options: host=#{host}, port=#{port}"

        port = new Port port
        app.set 'port', port.toString()

        server = http.createServer app

        onError = (error) ->
          console.error 'Server error occurred'
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
          actualPort = addr.port ? addr
          console.log "Server listening on #{host}:#{actualPort}"
          console.log "Ready to accept connections (press Ctrl+C to stop)"
          return

        server.listen port.toString(), host
              .on 'error',     onError
              .on 'listening', onListening

      stop: ->
        new Promise (resolve, reject) ->
          server.close resolve

