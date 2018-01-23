fs       = require 'fs'
path     = require 'path'

express  = require 'express'
router   = express.Router()

debug    = (require 'debug') "router:resume"

YAML     = require 'js-yaml'
pug      = require 'pug'
htmlDocx = require 'html-docx-js'
pdf      = require 'html-pdf'
cs       = require 'coffeescript'
moment   = require 'moment'

date     = (t) -> moment(t).format 'YYYY-MM-DD'

read     = (f) -> fs.readFileSync(f).toString()

{formats} = require '../lib/formats'

send = (res, resumé) ->
  app    = require '../app'
  format = formats[app.settings.config.format]
  debug "format: %O", format
  {type, extension, converter} = format

  Promise.resolve converter resumé
    .catch (e) -> res.send e

    .then (rendered) ->
      if type
        res.set 'Content-Type', type
        res.set """ "Content-Disposition", "attachment; filename="2018 resumé of Robert de Forest.#{extension}" """.trim()

      res.send rendered

router.get '/:format', (req, res, next) ->
  app    = require '../app'
  resumé = (require path.resolve app.settings.config.data) require '../lib/builder'
  app.settings.config.format = req.params.format
  send res, resumé
  return

module.exports = router
