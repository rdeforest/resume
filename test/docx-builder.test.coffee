{test}   = require 'node:test'
assert   = require 'node:assert/strict'

JSZip    = require 'jszip'          # ships with docx, which writes the file

{resumé} = require './helpers'

buildDocx = require '../lib/docx-builder'

# The document description is opaque class instances, so the XML docx actually
# emits is the honest thing to assert against.
documentXml = ->
  buffer = await buildDocx resumé()
  zip    = await JSZip.loadAsync buffer
  zip.file('word/document.xml').async 'string'

textRuns = (xml) ->
  (xml.match(/<w:t(?:\s[^>]*)?>[\s\S]*?<\/w:t>/g) ? [])
    .map (run) -> run.replace(/^<w:t(?:\s[^>]*)?>/, '').replace /<\/w:t>$/, ''

test 'produces a zip container', ->
  buffer = await buildDocx resumé()
  assert.equal buffer[0...2].toString('binary'), 'PK'

# Heredoc line breaks used to land literally inside <w:t>.
test 'no text run carries a literal newline', ->
  offenders = textRuns(await documentXml()).filter (run) -> run.includes '\n'
  assert.deepEqual offenders, []

test 'the intro is collapsed onto one line', ->
  runs = textRuns await documentXml()
  assert.ok 'First line of intro second line of intro.' in runs

test 'a summary is collapsed onto one line', ->
  runs = textRuns await documentXml()
  assert.ok 'A summary that wraps across source lines.' in runs

# A whitespace-only summary used to emit a paragraph containing only spaces,
# plus the spacing paragraph that follows a summary.
test 'no text run is whitespace only', ->
  offenders = textRuns(await documentXml()).filter (run) ->
    run isnt '' and run.trim() is ''

  assert.deepEqual offenders, []

# TextRun renders a numeric text as <w:t/>, so numeric from/to dates vanished.
test 'no text run is empty', ->
  xml = await documentXml()
  assert.deepEqual (xml.match(/<w:t(?:\s[^>]*)?\/>/g) ? []), []

test 'numeric dates still render as text', ->
  runs = textRuns await documentXml()

  assert.ok '1842' in runs, 'numeric `to` should render'
  assert.ok '1840' in runs, 'numeric `from` should render'

test 'a blanked group and an empty title produce no runs', ->
  runs = textRuns await documentXml()

  assert.ok 'Blanked Out' in runs
  assert.equal (runs.filter (run) -> run is 'Notes').length, 1  # the real group survives

test 'nested deliverables get their own indent level', ->
  xml    = await documentXml()
  levels = new Set (xml.match(/<w:ilvl w:val="\d+"\/>/g) ? [])

  assert.ok levels.has '<w:ilvl w:val="0"/>'
  assert.ok levels.has '<w:ilvl w:val="1"/>'
