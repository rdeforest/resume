byCommaSpace = (s) -> s.split /,\s*/

prevWithChanges = ->
  prev = {}

  (diff) ->
    for k, v of diff
      if v is undefined
        delete prev[k]
      else
        prev[k] = v

    Object.assign {}, prev, diff

job = prevWithChanges()

module.exports = { byCommaSpace, prevWithChanges, job }
