# Given a grid, x, y and new 'color', return the result of applying a flood fill to the grid

test = (inputs, outputs) ->
  preservedGrid = inputs.grid.map (row) -> Array.from row

  gridUnmolested = (before, after) ->
    if before isnt after
      try
        assert.deepEqual before, after
        return true

  # TODO: write a check for the fill being 'correct'

fillArgsCheck = (grid, x, y, color) ->
  if not height = grid.height = grid.length
    throw new Error "invalid grid: must be at least one row tall"

  if not width = grid.width = grid[0].length
    throw new Error "invalid grid: must be at least one column wide"

  if not validLocation x, y, width, height
    throw new Error "invalid location"

immediateNeighbors =
    [ [ 1,  0],
      [ 0,  1],
      [-1,  0],
      [ 0, -1] ]

allNeighbors =
    [ immediateNeighbors...,
      [ 1,  1]
      [-1,  1]
      [-1, -1]
      [ 1, -1] ]

validLocation = (x, y, X, Y) -> (0 <= x < X) and (0 <= y < Y)

# OO solution with no attempt to be efficient

class FillablePixel
  @neighbors = -> immediateNeighbors

  neighbors: ->
    @constructor
      .neighbors()
      .map ([dx, dy]) -> [nx, ny] = [@x + dx, @y + dx]
      .filter ([x, y]) -> validLocation x, y, @grid.width, @grid.height

  constructor: (@grid, @x, @y) ->
    @neighbors = []
    @neighbors.push -> new Pixel @grid, @x - 1, @y if @x > 0

  fill: (newColor) ->
    return if @color is newColor

    oldColor = @color

    @color = newColor

    @neighbors()
      .filter  (pixel) -> pixel.color is oldColor
      .forEach (pixel) -> pixel.fill newColor

    return @

Object.defineProperties Pixel::,
  color:
    get:            -> @grid[@y][@x]
    set: (newColor) -> @grid[@y][@x] = newColor

class LeakyFillablePixel
  @neighbors = -> allNeighbors

ooFill = (grid, x, y, color, pixelClass) ->
  fillArgsCheck arguments...

  (new pixelClass grid, x, y).fill color

# fake stack solution

fakeStackFill = (grid, x, y, color, neighborLocations = immediateNeighbors) ->
  fillArgsCheck arguments...

  [height, width] = [grid.length, grid[0].length]
  startColor      = grid[y][x]
  border          = [[x, y]]

  while border
    [x, y] = border.shift()

    border = border.concat(
      neighborLocations
        .map ([dx, dy]) -> [x + dx, y + dy]
        .filter ([x, y]) -> validLocation(x, y, width, height) and grid[y][x] is startColor

# bulk-op optimized solution


