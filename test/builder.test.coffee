{test}  = require 'node:test'
assert  = require 'node:assert/strict'

{byCommaSpace, prevWithChanges} = require '../lib/builder'

test 'byCommaSpace splits on commas with or without spaces', ->
  assert.deepEqual (byCommaSpace 'a, b,c'), ['a', 'b', 'c']

test 'job() carries unmentioned fields forward', ->
  job = prevWithChanges()

  job company: 'First', title: 'Engineer'
  assert.equal (job company: 'Second').title, 'Engineer'

test 'job() overrides a field that is mentioned again', ->
  job = prevWithChanges()

  job company: 'First', title: 'Engineer'
  assert.equal (job title: 'Manager').title, 'Manager'

# This is why three positions carry a whitespace-only summary: dropping the key
# would inherit the previous job's, and only an explicit value clears it.
test 'job() clears a field set to undefined', ->
  job = prevWithChanges()

  job company: 'First', summary: 'inherited'
  assert.equal (job company: 'Second', summary: undefined).summary, undefined

test 'job() does not leak state between builders', ->
  first  = prevWithChanges()
  second = prevWithChanges()

  first company: 'First'
  assert.equal (second title: 'Solo').company, undefined
