
class ChildProcess
  @blessedMethods = {}
  @bless: (method) ->

  constructor: (@process) ->
    @blessedMethods = Object.assign {}, ChildProcess.blessedMethods

    @process.on 'message',
      {method, args = []}

      if @blessedMethods[method]
        try
          process.send ok: @[method] args...
        catch e
          process.send err: e
      else
        if 'function' is typeof @[method]
          process.send err: new Error "Method #{method} has not been blessed"



process
  .on 'message',
    (m) ->
      {name, args} = m


process
  .send status: 'started'

process.on 'exit', -> process.send status: 'ending'
