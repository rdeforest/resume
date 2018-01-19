module.exports = (stdout) ->
  cat: (files) ->
    files
      .map (f) ->
        for retry in [3..1]
          try
            return fs.readFileSync f
      .join ''

  echo: (s) -> stdout.write s

