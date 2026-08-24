{test}    = require 'node:test'
assert    = require 'node:assert/strict'
fs        = require 'node:fs'
{resolve} = require 'node:path'

{scratch, resumé} = require './helpers'

{writeFormats, outputPath, serialize} = require '../lib/generate'

magic = (file, bytes) ->
  fs.readFileSync(file)[0...bytes.length].toString 'binary'

test 'outputPath swaps the extension beside the destination', ->
  assert.equal (outputPath '/srv/public/resume.html', 'pdf'),
               '/srv/public/resume.pdf'

test 'serialize passes buffers and strings through untouched', ->
  buffer = Buffer.from 'raw'

  assert.equal (serialize buffer), buffer
  assert.equal (serialize 'text'), 'text'

test 'serialize renders anything else as indented JSON', ->
  assert.equal (serialize {a: 1}), '{\n  "a": 1\n}'

test 'writeFormats produces a real PDF and DOCX', ->
  destination = resolve (scratch 'generate'), 'resume.html'

  written = await writeFormats resumé(), destination

  pdf  = outputPath destination, 'pdf'
  docx = outputPath destination, 'docx'

  assert.ok pdf  in written
  assert.ok docx in written

  assert.equal (magic pdf,  '%PDF'), '%PDF'
  assert.equal (magic docx, 'PK'),   'PK'      # docx is a zip container

test 'writeFormats also emits yaml and json, and never html', ->
  destination = resolve (scratch 'generate'), 'resume.html'

  written = await writeFormats resumé(), destination

  assert.ok (outputPath destination, 'yaml') in written
  assert.ok (outputPath destination, 'json') in written
  assert.ok (outputPath destination, 'html') not in written
  assert.equal fs.existsSync(destination), false

test 'writeFormats leaves no .new temp files behind', ->
  dir         = scratch 'generate'
  destination = resolve dir, 'resume.html'

  await writeFormats resumé(), destination

  leftovers = fs.readdirSync(dir).filter (name) -> name.endsWith '.new'
  assert.deepEqual leftovers, []

test 'the json output round-trips the résumé data', ->
  destination = resolve (scratch 'generate'), 'resume.html'

  await writeFormats resumé(), destination

  parsed = JSON.parse fs.readFileSync (outputPath destination, 'json'), 'utf8'
  assert.equal parsed.contact.name, 'Ada Lovelace'
  assert.equal parsed.positions.length, 2
