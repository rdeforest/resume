express      = require 'express'
path         = require 'path'
favicon      = require 'serve-favicon'
logger       = require 'morgan'
cookieParser = require 'cookie-parser'
bodyParser   = require 'body-parser'
index        = require './routes/index'
resume       = require './routes/resume'

app          = express()

# view engine setup
app.set 'views',       path.join(__dirname, 'views')
app.set 'view engine', 'pug'

app.use logger('dev')
app.use bodyParser.json()
app.use bodyParser.urlencoded(extended: false)
app.use cookieParser()

app.use express.static(path.join(__dirname, 'public'))

app.use '/', index
app.use '/resume', resume

app.use (req, res, next) ->
  err = new Error('Not Found')
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
