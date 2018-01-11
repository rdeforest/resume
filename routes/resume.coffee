express = require('express')
router = express.Router()

router.get '/:format', (req, res, next) ->
  resume     = require '../data/projects/resume.coffee'
  { format } = req.params

  switch format
    when 'html' then res.send pug.render template, resume
    when 'json' then res.send                      resume
    when 'yaml' then res.send YAML.safeDump        resume
    #when 'md'   then res.send ...

  return

module.exports = router
