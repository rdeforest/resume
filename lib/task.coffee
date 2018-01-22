EventEmitter = require 'events'

module.exports = ({task, config}) ->
  class Task extends EventEmitter
    constructor: (nameAndDetails) ->
      for @name, details of nameAndDetails
        for name, detail of details
          @addDetail name, detail

    addDetail: (name, detail) ->
      if 'function' is typeof @[setter = "set_#{name}"]
        @[setter] detail
        return @
