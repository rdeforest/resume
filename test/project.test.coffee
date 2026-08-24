{test}    = require 'node:test'
assert    = require 'node:assert/strict'
fs        = require 'node:fs'
{resolve} = require 'node:path'

{scratch, envroot} = require './helpers'

Project = require '../lib/project'

template = resolve envroot, 'data', 'themes', 'table-based', 'main.pug'

# Writes a data module and returns a Project pointed at it.
project = (dir, name) ->
  data = resolve dir, "#{name}.coffee"

  fs.writeFileSync data, """
    module.exports = ({byCommaSpace, job}) ->
      contact:   {name: 'Ada', email: 'a@b.c', phone: '1'}
      intro:     'intro'
      keywords:  {Modes: ['Curious']}
      positions: [job {company: 'Co', from: '1', to: '2', summary: 's', delivered: ['d']}]
  """

  new Project {data, template, destination: resolve dir, "#{name}.html"}

test 'changed() is true before a first refresh', ->
  assert.ok project(scratch('project'), 'a').changed()

test 'changed() is false when nothing has moved', ->
  p = project scratch('project'), 'b'
  p.refresh()

  assert.equal p.changed(), false

# rehash() hashed '' for every input while cat was broken, so an edited data
# file looked identical to the previous one and regen never ran again.
test 'changed() notices an edit to the data file', ->
  dir = scratch 'project'
  p   = project dir, 'c'
  p.refresh()

  fs.appendFileSync (resolve dir, 'c.coffee'), "\n# a change\n"

  assert.ok p.changed(), 'an edited data file must re-hash differently'

test 'refresh() writes html to the destination', ->
  dir = scratch 'project'
  p   = project dir, 'd'
  p.refresh()

  html = fs.readFileSync (resolve dir, 'd.html'), 'utf8'
  assert.match html, /Ada/

test 'refresh() leaves no .new temp file behind', ->
  dir = scratch 'project'
  project(dir, 'e').refresh()

  leftovers = fs.readdirSync(dir).filter (name) -> name.endsWith '.new'
  assert.deepEqual leftovers, []

# Project.data() used to hand back require's cached copy, so watch mode
# regenerated the old résumé no matter how often the data file changed.
test 'data() reflects an edit rather than the require cache', ->
  dir = scratch 'project'
  p   = project dir, 'f'

  assert.equal p.data().contact.name, 'Ada'

  fs.writeFileSync (resolve dir, 'f.coffee'), """
    module.exports = ({job}) ->
      contact:   {name: 'Grace', email: 'a@b.c', phone: '1'}
      intro:     'intro'
      keywords:  {Modes: ['Curious']}
      positions: []
  """

  assert.equal p.data().contact.name, 'Grace'
