fs       = require 'fs'

moment   = require 'moment'

YAML     = require 'js-yaml'
pug      = require 'pug'
htmlDocx = require 'html-docx-js'
pdf      = require 'html-pdf'

read     = (f) -> fs.readFileSync(f).toString()

module.exports =
  formats:
    html: name: 'HTML', converter: html = (resumé) ->
      {settings: {config}} = require '../app'
      {template} = config
      pugLocals = Object.assign {}, resumé,
                                    filename: config.template
                                    pretty:   true
                                    config

      pug.render read(template), pugLocals

    pdf:
      name: 'PDF'
      type: 'application/pdf'
      extension: 'pdf'
      converter: (resumé) ->
        new Promise (resolve, reject) ->
          pdf.create html resumé
             .toBuffer (err, buffer) ->
               if err then reject err else resolve buffer

    yaml: name: 'YAML', converter: YAML.safeDump
    json: name: 'JSON', converter: (resumé) -> resumé

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
