YAML     = require 'js-yaml'
pug      = require 'pug'
htmlDocx = require 'html-docx-js'
pdf      = require 'html-pdf'

config   = ->
  conf = (require '../app').config

  Object.assign conf,
    updated:    date fs.statSync conf.data
    generated:  date()


module.exports =
  formats:
    yaml: name: 'YAML', converter: YAML.safeDump
    json: name: 'JSON', converter: (resumé) -> resumé
    html: name: 'HTML', converter: html = (resumé) ->
      pugLocals = Object.assign {}, resumé,
                                    filename: config().template
                                    pretty:   true
                                    config()

      pug.render template(), pugLocals

    pdf:
      name: 'PDF'
      type: 'application/pdf'
      extension: 'pdf'
      converter: (resumé) ->
        new Promise (resolve, reject) ->
          pdf.create html resumé
             .toBuffer (err, buffer) ->
               if err then reject err else resolve buffer

  futureFormats:
    docx:
      name: 'DOCX'
      type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
      extension: 'docx'
      converter: (resumé) -> htmlDocx.asBlob html resumé

    markdown:   name: 'Markdown'
    plain:      name: 'Plain text'
    postscript: name: 'PostScript'
    latex:      name: 'LaTeX?'
