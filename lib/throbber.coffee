getters = (o, namesAndDefs) ->
  defs = {}

  for name, def of namesAndDefs
    defs[name] = get: def

  Object.defineProperties o, defs

module.exports =
class Throbber
  constructor: (@stages) ->
    @angle = 0
    spaces = 0

    for stage, idx in @stages[1..]
      spaces = diff = @stages[idx].length - stage.length - spaces

      if diff > 0
        @stages[idx + 1] += ' '.repeat diff
      else
        spaces = 0

      @stages[idx + 1] += '\r'

  throb: -> @stages[@angle = (@angle + 1) % @stages.length]

(getters Throbber, (do (name, value) -> [name]: -> new Throbber value)) for name, value of {
    spinner:  ''' ^ ' > . v , < ` '''.split /\s+/
    upDown:   ''' _-¯- '''.split /\s+/
    circle:   ''' . o O 0 O o '''.split /\s+/
    line:     [0..5]
                .concat [0..4].reverse()
                .map (n) -> "-".repeat n

  }
