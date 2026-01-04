{env, argv, stdout} =
process        =  require 'process'
fs             =  require 'fs'
crypto         =  require 'crypto'
path           =  require 'path'

cs             =  require 'coffeescript'
YAML           =  require 'js-yaml'

pug            =  require 'pug'

{cat, echo}    = (require './util') process.stdout

log            = (require 'debug') 'Project'

module.exports =
class Project
  constructor: ({data: @_dataFile, @template, @destination, @tmp}) ->
    @tmp ?= @destination + ".new"
    @hash = ''
    @sources = [@_dataFile, @template]

    if not @tmp
      throw new Error 'wat'

  data: ->
    contents = fs.readFileSync @_dataFile, 'utf8'
    switch
      when @_dataFile.endsWith 'coffee'
        dataModule = require path.resolve @_dataFile
        builder    = require './builder'
        if 'function' is typeof dataModule
          dataModule builder
        else
          dataModule
      when @_dataFile.endsWith 'yaml'   then YAML.load     contents
      when @_dataFile.endsWith 'json'   then JSON.parse    contents
      else throw new Error "Format of file #{@_dataFile} could not be derived from its name"

  rehash: ->
    crypto
      .createHash 'sha256'
      .update cat Object.values @sources
      .digest 'hex'

  changed: -> @hash isnt (newHash = @rehash()) and newHash

  refresh: (newHash = @rehash()) ->
    @hash = newHash
    template = fs.readFileSync @template, 'utf8'
    options  = Object.assign @data(),
      filename: @template
      pretty:   true

    log JSON.stringify {template, options}
    html = pug.render template, options
    fs.writeFileSync @tmp, html
    fs.renameSync @tmp, @destination
    @rehash()


