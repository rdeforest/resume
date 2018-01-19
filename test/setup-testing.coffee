merged  = (entries) -> Object.assign {}, entries...

getters = (o, namesAndValues) ->
  defs = Object
    .entries namesAndValues
    .map ([name, value]) -> [name]: get: value

  Object.defineProperties o, merged defs

getters String::,
  qw: get: -> @.split /\s+/

{ env } =
process = require 'process'

env.NODE_PATH =
  env.NODE_PATH.split ':'
    .concat '../lib'
    .join ':'

moduleNames = 'assert fs events path util'.qw

env.JOE_REPORTER ?= 'console'

Object.assign global,
              require('joe')
              {process}
              (moduleNames.map (mod) -> "#{mod}": require mod)...
