fs        = require 'fs'
path      = require 'path'

{formats} = require './formats'

# formats.html pulls its template locals from the express app; Project renders
# the same pug directly, so regen drives html through Project and skips it here.
generated = (name) -> name isnt 'html'

serialize = (output) ->
  switch
    when Buffer.isBuffer output      then output
    when 'string' is typeof output   then output
    else JSON.stringify output, null, 2

# public/ is served straight off disk, so land each file with a rename rather
# than letting a reader see a half-written one.
write = (file, contents) ->
  tmp = "#{file}.new"
  fs.writeFileSync tmp, contents
  fs.renameSync tmp, file
  file

outputPath = (destination, extension) ->
  base = path.basename destination, path.extname destination
  path.join (path.dirname destination), "#{base}.#{extension}"

# Renders every non-html format beside `destination`, resolving to the paths
# written. One format failing must not cost the others, so failures are
# collected and thrown together once the rest have landed.
writeFormats = (resumé, destination) ->
  attempts = Object.keys(formats).filter(generated).map (name) ->
    {converter, extension} = formats[name]
    file = outputPath destination, extension or name

    Promise.resolve converter resumé
      .then    (output) -> {name, file: write file, serialize output}
      .catch   (error)  -> {name, error}

  Promise.all(attempts).then (results) ->
    failed = results.filter ({error}) -> error?

    if failed.length
      throw new Error failed
        .map ({name, error}) -> "#{name}: #{error.message}"
        .join '\n'

    results.map ({file}) -> file

module.exports = {writeFormats, outputPath, serialize}
