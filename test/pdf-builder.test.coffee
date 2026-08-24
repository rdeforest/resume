{test}   = require 'node:test'
assert   = require 'node:assert/strict'

{resumé} = require './helpers'

{definition} = require '../lib/pdf-builder'

doc       = -> definition resumé()
positions = -> doc().content[1].table.body
header    = -> doc().content[0].table.body[0]

test 'page is US Letter', ->
  assert.equal doc().pageSize, 'LETTER'

test 'heredoc line breaks are collapsed in the intro', ->
  assert.equal header()[1].text, 'First line of intro second line of intro.'

test 'heredoc line breaks are collapsed in a summary', ->
  [summary] = positions()[0][2].stack
  assert.equal summary.text, 'A summary that wraps across source lines.'

# Three positions blank an inherited summary with a whitespace-only heredoc.
# Treating that as present emitted an empty paragraph plus its bottom margin,
# pushing the bullets ~10.8pt below the company name.
test 'a whitespace-only summary produces no paragraph at all', ->
  {stack} = positions()[1][2]

  assert.equal stack.length, 1
  assert.ok stack[0].ul, 'the only node should be the bullet list'

test 'a whitespace-only group and an empty title are omitted', ->
  {stack} = positions()[1][1]

  assert.equal stack.length, 1
  assert.equal stack[0].text, 'Blanked Out'

test 'deliverables nest rather than flatten', ->
  [, list] = positions()[0][2].stack

  assert.deepEqual list.ul[0], 'Top level'
  assert.deepEqual list.ul[1], ul: ['Nested one', 'Nested two']

test 'the keywords colSpan gets one filler cell per extra column', ->
  [favorites] = header()[2].table.body
  categories  = Object.keys resumé().keywords

  assert.equal favorites[0].colSpan, categories.length
  assert.equal favorites.length,     categories.length
  assert.deepEqual favorites[1..],   [{}]

test 'every keyword row has one cell per category', ->
  [, , rows...] = header()[2].table.body
  categories    = Object.keys resumé().keywords

  assert.ok rows.length > 0
  for row in rows
    assert.equal row.length, categories.length

test 'a category shorter than the tallest is padded with empty cells', ->
  [, , rows...] = header()[2].table.body

  # Languages has one entry, Modes has two.
  assert.equal rows[1][1].text, ''

test 'numeric dates are coerced to text', ->
  {stack} = positions()[1][0]

  assert.deepEqual (node.text for node in stack), ['1842', 'to', '1840']

test 'contact email carries a mailto link', ->
  [, email] = header()[0].stack
  assert.equal email.link, 'mailto:ada@example.org'
