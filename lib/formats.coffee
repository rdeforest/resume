fs         = require 'fs'

moment     = require 'moment'

YAML       = require 'js-yaml'
pug        = require 'pug'
HTMLtoDOCX = require 'html-to-docx'
pdf        = require 'html-to-pdf-pup'

date     = (t) -> moment(t).format 'YYYY-MM-DD'
read     = (f) -> fs.readFileSync(f).toString()

config   = ->
  conf = (require '../app').config

  Object.assign conf,
    updated:    date fs.statSync conf.data
    generated:  date()

template = -> read config().template

html = (resumé) ->
  pugLocals = Object.assign {}, resumé,
                                filename: config().template
                                pretty:   true
                                config()

  pug.render template(), pugLocals

module.exports =
  formats:
    yaml: name: 'YAML', converter: YAML.dump
    json: name: 'JSON', converter: (resumé) -> resumé
    html: name: 'HTML', converter: html
    pdf:
      name: 'PDF'
      type: 'application/pdf'
      extension: 'pdf'
      converter: (resumé) ->
        pdf.create_pdf html resumé
        # new Promise (resolve, reject) ->
        #   pdf.create html resumé
        #      .toBuffer (err, buffer) ->
        #        if err then reject err else resolve buffer

    docx:
      name: 'DOCX'
      type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
      extension: 'docx'
      converter: (resumé) -> HTMLtoDOCX html resumé

  futureFormats:
    markdown:   name: 'Markdown'
    plain:      name: 'Plain text'
    postscript: name: 'PostScript'
    latex:      name: 'LaTeX?'
