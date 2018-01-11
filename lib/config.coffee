fs   = require 'fs'
YAML = require 'js-yaml'

module.exports =
class Config
  @comment: '''
    I manage configuration information in a way which makes smart defaults easier.

    Usage:

        (myConfig = new Config {dumb defaults...})
          .load 'someYAMLFile'
          ._
            foo: -> derivation of foo
            bar: -> derivation of bar using myConfig.foo

    The value of the ::_ method is that each member of the config object can
    be defined in terms of its predecessors.
  '''

  constructor: (defaults = {}) ->
    Object.assign @, defaults

  load: (file) ->
    conf = YAML.safeLoad fs.readFileSync file
    delete conf._
    Object.assign @, conf

  _: (more) ->
    @[k] ?= v() for k, v of more

    @

