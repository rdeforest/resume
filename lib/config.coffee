fs   = require 'fs'
YAML = require 'js-yaml'

module.exports =
class Config
  constructor: (defaults = {}) ->
    Object.assign @, defaults

  load: (file) ->
    conf = YAML.safeLoad fs.readFileSync file
    delete conf._
    Object.assign @, conf

  _: (more) ->
    @[k] ?= v() for k, v of more

    @

