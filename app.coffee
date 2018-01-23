fs           = require 'fs'
path         = require 'path'

express      = require 'express'
favicon      = require 'serve-favicon'
logger       = require 'morgan'
cookieParser = require 'cookie-parser'
bodyParser   = require 'body-parser'

moment       = require 'moment'

index        = require './routes/index'
resume       = require './routes/resume'

app          = express()

date         = (t) -> moment(t).format 'YYYY-MM-DD'

app.set 'views',       path.join __dirname, 'views'
app.set 'view engine', 'pug'

app.set 'envroot', envroot = __dirname
app.set 'config',  (config = new (require './lib/config') {envroot}).load 'config.yaml'
Object.assign config,
  updated:    date fs.statSync config.data
  generated:  date()

app.use logger 'dev'
app.use bodyParser.json()
app.use bodyParser.urlencoded extended: false
app.use cookieParser()

app.use express.static path.join __dirname, 'public'

app.use '/', index
app.use '/resume', resume

app.use (req, res, next) ->
  err = new Error 'Not Found'
  err.status = 404
  next err
  return

app.use (err, req, res, next) ->
  # set locals, only providing error in development
  res.locals.message = err.message
  res.locals.error = if req.app.get('env') == 'development' then err else {}

  # render the error page
  res.status err.status or 500
  res.render 'error'
  return

module.exports = app
