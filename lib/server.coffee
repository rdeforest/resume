debug  = require('debug') 'resume:server'

class Port
  constructor: (@str) ->
    port = parseInt @str, 10

    switch
      when isNaN port then @value = @pipe = val
      when port >= 0  then @value = @port = port


Object.defineProperties Port::,
  name:     get: -> @typeName + ' ' + @str
  typeName: get: -> if @pipe then 'Pipe' else 'Port'

module.exports =
  start = (options) ->
    debug 'Starting server...'
    app    = require '../app'
    http   = require 'http'

    port = new Port process.env.PORT or '3000'
    app.set 'port', port.value

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


    server.listen port
          .on 'error',     onError
          .on 'listening', onListening

    start.stop = ->
      new Promise (resolve, reject) ->
        server.close resolve

exports.module = module
