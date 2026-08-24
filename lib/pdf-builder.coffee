pdfmake = require 'pdfmake'

# FreeSans (what the theme and the DOCX builder ask for) is a Helvetica metric
# clone. PDFKit has Helvetica built in, so nothing needs embedding or shipping.
standardFonts =
  normal:      'Helvetica'
  bold:        'Helvetica-Bold'
  italics:     'Helvetica-Oblique'
  bolditalics: 'Helvetica-BoldOblique'

pdfmake.addFonts Helvetica: standardFonts

# Résumé data has no images or links to fetch; deny everything except the
# built-in font names, which pdfmake routes through the local-file policy.
allowedPaths = new Set Object.values standardFonts

pdfmake.setUrlAccessPolicy   -> false
pdfmake.setLocalAccessPolicy (path) -> allowedPaths.has path

size =
  body:      8
  name:     12
  contact:   9
  intro:     9
  favorites: 7
  category:  6
  keyword:   6
  timeline:  9
  company:  10
  group:     9
  title:     9
  summary:   7
  bullet:    7

# Heredocs in the data keep their source line breaks; pdfmake honours them.
# Blanked-out fields arrive as whitespace-only strings (the data uses those to
# stop prevWithChanges carrying a value forward), so collapsing decides absence.
prose   = (s) -> String(s ? '').replace(/\s+/g, ' ').trim()
compact = (l) -> l.filter (item) -> item?
spanFill = (n) -> [1...n].map -> ({})   # placeholder cells a colSpan needs

bare = (padding = {}) ->
  hLineWidth:    -> 0
  vLineWidth:    -> 0
  paddingLeft:   padding.left   or -> 0
  paddingRight:  padding.right  or -> 0
  paddingTop:    padding.top    or -> 0
  paddingBottom: padding.bottom or -> 0

contactColumn = (contact) ->
  stack: [
    {text: contact.name,  bold: true, fontSize: size.name, margin: [0, 0, 0, 2]}
    {text: contact.email, link: "mailto:#{contact.email}", fontSize: size.contact}
    {text: contact.phone, fontSize: size.contact}
  ]

introColumn = (intro) ->
  text:       prose intro
  fontSize:   size.intro
  lineHeight: 1.3

keywordsTable = (keywords) ->
  categories = Object.keys keywords
  depth      = Math.max (keywords[name].length for name in categories)...

  favorites  = [
    text:      'A Few Of My Favorite ...'
    italics:   true
    fontSize:  size.favorites
    alignment: 'center'
    colSpan:   categories.length
  ].concat spanFill categories.length

  names = categories.map (name) ->
    text:      name
    bold:      true
    italics:   true
    fontSize:  size.category
    alignment: 'center'

  rows = [0...depth].map (row) ->
    categories.map (name) ->
      text:      keywords[name][row] or ''
      fontSize:  size.keyword
      alignment: 'center'

  table:
    widths: categories.map -> '*'
    body:   [favorites, names].concat rows
  layout: bare()

headerTable = (contact, intro, keywords) ->
  table:
    widths: ['20%', '40%', '40%']
    body:   [[
      contactColumn contact
      introColumn   intro
      keywordsTable keywords
    ]]
  layout: bare
    left:  (col) -> if col is 1 then 8 else 0
    right: (col) -> if col is 1 then 8 else 0
  margin: [0, 4, 0, 8]

bulletList = (items) ->
  ul: items.map (item) ->
    if 'string' is typeof item then prose item else bulletList item

timelineCell = (job) ->
  return text: '' unless job.from

  fontSize: size.timeline
  stack: [
    {text: "#{job.to}",   alignment: 'center'}
    {text: 'to',          alignment: 'center'}
    {text: "#{job.from}", alignment: 'center'}
  ]

headerCell = (job) ->
  [company, group, title] = (prose job[field] for field in ['company', 'group', 'title'])

  stack: compact [
    {text: company, bold: true, fontSize: size.company}
    {text: group,   fontSize: size.group}                 if group
    {text: title,   italics: true, fontSize: size.title}  if title
  ]

contentCell = (job) ->
  summary = prose job.summary

  stack: compact [
    if summary
      text:       summary
      fontSize:   size.summary
      lineHeight: 1.2
      margin:     [0, 0, 0, 3]
    if job.delivered?.length
      Object.assign bulletList(job.delivered), fontSize: size.bullet
  ]

positionsTable = (positions) ->
  table:
    widths:       ['10%', '25%', '65%']
    dontBreakRows: true
    body:          positions.map (job) ->
      [timelineCell(job), headerCell(job), contentCell(job)]
  layout: bare
    right:  (col) -> if col < 2 then 6 else 0
    bottom: (row, node) -> if row < node.table.body.length - 1 then 10 else 0

definition = (resumé) ->
  {contact, intro, keywords, positions} = resumé

  pageSize:     'LETTER'
  pageMargins:  [21.6, 21.6, 21.6, 21.6]   # 0.3in, matching the theme CSS
  defaultStyle: {font: 'Helvetica', fontSize: size.body}
  info:
    title:  "Resume of #{contact.name}"
    author: contact.name
  content: [
    headerTable    contact, intro, keywords
    positionsTable positions
  ]

buildPdf = (resumé) -> pdfmake.createPdf(definition resumé).getBuffer()

# The document definition is the part worth asserting against in tests; the
# buffer is pdfmake's business.
module.exports = buildPdf
module.exports.definition = definition
