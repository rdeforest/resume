{env, argv, stdout} =
process        =  require 'process'
fs             =  require 'fs'
crypto         =  require 'crypto'
path           =  require 'path'

cs             =  require 'coffeescript'
pug            =  require 'pug'

{cat, echo}    = (require './util') process.stdout

module.exports =
class Project
  constructor: ({data: @_dataFile, @template, @css, @dst, @tmp}) ->
    @tmp ?= @dst + ".new"
    @hash = ''
    @sources = [@_dataFile, @template, @css]

    if not @tmp
      throw new Error 'wat'

  data: -> cs.eval fs.readFileSync @_dataFile, 'utf8'

  rehash: ->
    crypto
      .createHash 'sha256'
      .update cat Object.values @sources
      .digest 'hex'

  changed: -> @hash isnt (newHash = @rehash()) and newHash

  refresh: (newHash = @rehash()) ->
    @hash = newHash
    template = fs.readFileSync @template
    options  = Object.assign @data(),
      filename: @template
      pretty:   true

    html = pug.render template, options
    fs.writeFileSync @tmp, html
    fs.renameSync @tmp, @dst
    @rehash()


