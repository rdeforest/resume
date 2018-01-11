YAML        = require 'js-yaml'
marked      = require 'marked'

{ contact: {name, addr, phone, email}
  intro, positions
} =
resume      = require './resume'

qw          = (s)          -> s.split /s+/
commaList   = (strings...) -> strings.join ', '
bracketWitn = (left, right) -> (content) -> left + content + right

newLine     = '\n'
space       = ' '

bracketWith = (left, right) -> (s) -> left + s + right

em          = bracketWith '__'.split ''
strong      = bracketWith '**'.split ''

headn = (n) ->
  prefix = '#'.repeat n

  (content) -> newLine + prefix + space + content + newLine

head1 = headn 1
head2 = headn 2
head3 = headn 3
head4 = headn 4
head5 = headn 5

padStrings = (strings, widths) ->
  widths.map (w, i) ->
    s = strings[i] or ''

    String::[ if w > 0 then 'End' else 'Start' ]
      .call s, w

reduceGrid = (rows, rowReducer, cellReducer, acc) ->
  rows
    .map (row) -> row.reduce cellReducer, acc
    .reduce rowReducer

code = (typeAndContent) ->
  [].concat (
    Object
      .entries typeAndContent
      .map ([type, content]) -> ["```#{type}", content, "```"]
  )...

indent = (strings, pad = '  ') -> strings.map (s) -> pad + s

bulletList = (list) ->
  [].concat (
    list.map (item) ->
      if Array.isArray item
        indent bulletList item
      else
        " - #{item}"
  )...

keywords = ->
  [].concat (
    Object
      .entries resume.keywords
      .map ([title, contents]) ->
        [head3 title, ''].concat bulletList contents
  )...

jobSection = ({title, group, company, from, to, summary, delivered}) ->
  [
    "---"
    "Title:   #{title}"
    "Group:   #{group}"
    "Company: #{company}"
    "From:    #{from}"
    "To:      #{to}"
    ""
    "#{summary}"
    ""
    "_Delivered:_"
    ""
  ].concat bulletList(delivered)...

lines = [
    head1 name
    code address: commaList addr.street, addr.city, addr.state, addr.zip
    code phone:   phone
    code email:   email

    head1 'Keywords'

    keywords()

    head1 'Positions'
  ].concat (jobSection position for position in positions)...

console.log marked lines.join '\n'
