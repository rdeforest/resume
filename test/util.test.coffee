{test}    = require 'node:test'
assert    = require 'node:assert/strict'
fs        = require 'node:fs'
{resolve} = require 'node:path'

{scratch} = require './helpers'

{cat} = (require '../lib/util') process.stdout

# lib/util once referenced fs without requiring it, and a bare `try` swallowed
# the ReferenceError, so cat returned '' for every input. Project.rehash then
# hashed nothing and change detection silently stopped working.
test 'cat returns a file\'s actual contents', ->
  dir  = scratch 'util'
  file = resolve dir, 'one.txt'
  fs.writeFileSync file, 'hello'

  assert.equal cat([file]), 'hello'

test 'cat concatenates in the order given', ->
  dir = scratch 'util'
  for [name, body] in [['a.txt', 'aaa'], ['b.txt', 'bbb']]
    fs.writeFileSync (resolve dir, name), body

  assert.equal cat([(resolve dir, 'a.txt'), (resolve dir, 'b.txt')]), 'aaabbb'

test 'cat distinguishes differing contents', ->
  dir = scratch 'util'
  fs.writeFileSync (resolve dir, 'x.txt'), 'before'
  before = cat [resolve dir, 'x.txt']

  fs.writeFileSync (resolve dir, 'x.txt'), 'after'
  assert.notEqual before, cat [resolve dir, 'x.txt']

test 'cat propagates a genuinely missing file', ->
  assert.throws -> cat [resolve (scratch 'util'), 'does-not-exist']
