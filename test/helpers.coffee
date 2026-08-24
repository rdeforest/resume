fs        = require 'node:fs'
{resolve} = require 'node:path'

envroot = resolve __dirname, '..'

# Scratch space lives under the repo's tmp/ (gitignored) rather than /tmp.
scratch = (name) ->
  dir = resolve envroot, 'tmp', 'test', name
  fs.rmSync  dir, recursive: true, force: true
  fs.mkdirSync dir, recursive: true
  dir

# A résumé small enough to assert against, carrying the shapes that have
# actually broken: heredoc line breaks, a whitespace-only blanked field, and
# nested deliverables.
resumé = ->
  contact:
    name:  'Ada Lovelace'
    email: 'ada@example.org'
    phone: '+1 555 0100'

  intro: '''
    First line of intro
    second line of intro.
  '''

  keywords:
    Modes:     ['Curious', 'Careful']
    Languages: ['CoffeeScript']

  positions: [
    {
      company:   'Analytical Engines'
      group:     'Notes'
      title:     'Author'
      from:      '1842'
      to:        '1843'
      summary:   '''
        A summary that wraps
        across source lines.
      '''
      delivered: ['Top level', ['Nested one', 'Nested two']]
    }
    {
      company:   'Blanked Out'
      group:     '   '
      title:     ''
      from:      1840          # numeric on purpose: docx renders a number as an empty <w:t/>
      to:        1842
      summary:   '      '
      delivered: ['Only a bullet']
    }
  ]

module.exports = {scratch, resumé, envroot}
