fs      = require 'fs'

express = require 'express'
YAML    = require 'js-yaml'

router  = express.Router()

pug = require 'pug'

router.get '/:format', (req, res, next) ->
  config     = res.app.get 'config'
  resume     = Object.assign {},
    filename: config.template,
    YAML.safeLoad fs.readFileSync config.data

  template   = fs.readFileSync config.template
  { format } = req.params

  switch format
    when 'html' then res.send pug.render template, resume
    when 'json' then res.send                      resume
    when 'yaml' then res.send YAML.safeDump        resume
    #when 'md'   then res.send ...

  return

module.exports = router
