express = require 'express'
app = require '../app'

router = express.Router()

formats = require '../lib/formats'

router.get '/', (req, res, next) ->
  res.render 'index', Object.assign formats, title: 'Resume of Robert de Forest'
  return

module.exports = router
