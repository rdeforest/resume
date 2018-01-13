fs       = require 'fs'

express  = require 'express'
YAML     = require 'js-yaml'

router   = express.Router()

pug      = require 'pug'
htmlDocx = require 'html-docx-js'
pdf      = require 'html-pdf'

config   = -> (require '../app').config

template = -> fs.readFileSync config().template

formats =
  yaml: converter: YAML.safeDump
  json: converter: (resumé) -> resumé
  html: converter: html = (resumé) ->
    pugLocals = Object.assign {}, resumé,
                                  filename: config().template
                                  format:   config().format
                                  pretty:   true

    pug.render template(), pugLocals

  pdf:
    type: 'application/pdf'
    extension: 'pdf'
    converter: (resumé) ->
      new Promise (resolve, reject) ->
        pdf.create html resumé
           .toBuffer (err, buffer) ->
             if err then reject err else resolve buffer

  docx:
    type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
    extension: 'docx'
    converter: (resumé) -> htmlDocx.asBlob html resumé

send = (res, resumé) ->
  {format} = config()
  {type, extension, converter} = formats[format]

  Promise.resolve converter resumé
    .catch (e) -> res.send e

    .then (rendered) ->
      if type
        res.set 'Content-Type', type
        res.set """ "Content-Disposition", "attachment; filename="2018 resumé of Robert de Forest.#{extension}" """.trim()

      res.send rendered

router.get '/:format', (req, res, next) ->
  {data} = conf = config()

  resumé = YAML.safeLoad fs.readFileSync data
  conf.format = req.params.format
  send res, resumé
  return

module.exports = router
