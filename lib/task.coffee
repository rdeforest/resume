{env} = require 'process'

debug = (require 'debug') 'Task'

EventEmitter = require 'events'

module.exports = ({task, option}) ->
  class Task extends EventEmitter
    constructor: (nameAndDetails) ->
      super()
      @defaults = {}

      for @name, details of nameAndDetails
        for name, detail of details
          @addDetail name, detail

      if not (@name and @description and @start)
        throw new Error "Task requires a name, description and action"

      task @name, @description, (options) => @run options

    run: (options) ->
      debug "run: #{@name}"
      debug "defaults: %O", @defaults
      debug "options: %O", options

      for name, value of @defaults
        if undefined is options[name]
          debug "defaulting #{name} from %O to %s", @defaults[name],
            options[name] = @deriveDefault @defaults[name]
        else
          debug "#{name} is %s", options[name]

      @start options

    addDetail: (name, detail) ->
      if 'function' is typeof @[setter = "set_#{name}"]
        @[setter] detail
        return @

      @[name] = detail

    deriveDefault: (defaults) ->
      if Array.isArray defaults
        return defaults.find (def) => @deriveDefault def

      if 'object' is typeof defaults
        if defaults.env
          return env[defaults.env]

      defaults

    set_options: (nameAndDetails) ->
      for name, details of nameAndDetails
        if 'object' isnt typeof details
          details =
            defaults: details

        Object.assign details,
            long: "#{name} [string]"
            short: name[0]
            description: ""
            details

        debug "Adding option #{name}: %O", details
        option "-#{details.short}", "--#{details.long}", details.description
        @defaults[name] = details.defaults

