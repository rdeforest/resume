module.exports =
class Port
  constructor: (str) ->
    if isNaN (port = parseInt str, 10)
      @typeName = 'Pipe'
      @toString = -> str
    else
      @typeName = 'Port'
      @toString = -> port

Object.defineProperties Port::,
  name:     get: -> @typeName + ' ' + @toString()
