module.exports =
class Port
  constructor: (@str) ->
    port = parseInt @str, 10

    switch
      when isNaN port then @value = @pipe = val
      when port >= 0  then @value = @port = port

Object.defineProperties Port::,
  name:     get: -> @typeName + ' ' + @str
  typeName: get: -> if @pipe then 'Pipe' else 'Port'
