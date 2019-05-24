merged  = (entries) -> Object.assign {}, entries...

moduleNames = 'assert fs events path util'.qw
modules = merged moduleNames.map (mod) -> "#{mod}": require mod

getters = (o, namesAndValues) ->
  defs = Object
    .entries namesAndValues
    .map ([name, value]) -> [name]: get: value

  Object.defineProperties o, merged defs

getters String::,
  qw: get: -> @.split /\s+/

{ env }    =
process    = require 'process'
{ resolve} = require 'path'

env.NODE_PATH =
  env.NODE_PATH.split ':'
    .concat resolve __dirname, '..', 'lib'
    .join ':'

#env.JOE_REPORTER ?= 'console'

Object.assign global,
              require('kava')
              {process}
              {modules}
              {getters}
