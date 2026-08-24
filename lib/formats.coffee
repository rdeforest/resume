fs           = require 'fs'

moment       = require 'moment'

YAML         = require 'js-yaml'
pug          = require 'pug'
buildDocx    = require './docx-builder'
buildPdf     = require './pdf-builder'

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
      converter: buildPdf

    docx:
      name: 'DOCX'
      type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
      extension: 'docx'
      converter: buildDocx

  futureFormats:
    markdown:   name: 'Markdown'
    plain:      name: 'Plain text'
    postscript: name: 'PostScript'
    latex:      name: 'LaTeX?'
