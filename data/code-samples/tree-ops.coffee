# Operations on trees: search, add, remove, etc

# Assumes no loops (hence tree as opposed to graph).

invert = (fn) -> (args...) -> not fn args...

ArrayTree = (tree) ->
  wrapper = -> tree

  Object.assign wrapper,
    children: -> @()
    branches: -> @().filter        Array.isArray
    leaves  : -> @().filter invert Array.isArray

    flattened: ->
      @leaves().concat @children().map((c) -> c.flattened())...

    tryOp: (op, el) ->
      try
        return ret: op el
      catch err
        return {err}

    depthTraverse: (op, path, root = @) ->
      childrenReturned =
        for e, i in @()
          {ret, err} = @depthTraverse op, path.concat(i), root
          return {err} if err
          ret

      {ret, err} = @tryOp op e
      return {err} if err
      {children, ret}

    breadthTraverse: (op) ->
      branches = @()

      while branches.length
        branches =
          [].concat branches.map((branch) ->
              try op branch

              if Array.isArray branch
                branch = ArrayTree branch
              else
                []
            )...
