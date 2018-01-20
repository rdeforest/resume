fs       = require 'fs'
path     = require 'path'

express  = require 'express'
YAML     = require 'js-yaml'

router   = express.Router()

pug      = require 'pug'
htmlDocx = require 'html-docx-js'
pdf      = require 'html-pdf'
cs       = require 'coffeescript'
moment   = require 'moment'

date     = (t) -> moment(t).format 'YYYY-MM-DD'

read     = (f) -> fs.readFileSync(f).toString()

config   = ->
  conf = (require '../app').config

  Object.assign conf,
    updated:    date fs.statSync conf.data
    generated:  date()

template = -> read config().template

formats =
  yaml: converter: YAML.safeDump
  json: converter: (resumé) -> resumé
  html: converter: html = (resumé) ->
    pugLocals = Object.assign {}, resumé,
                                  filename: config().template
                                  pretty:   true
                                  config()

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

  resumé = (require path.resolve conf.data) require '../lib/builder'
  conf.format = req.params.format
  send res, resumé
  return

module.exports = router
