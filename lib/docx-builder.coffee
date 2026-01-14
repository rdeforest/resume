{Document, Paragraph, TextRun, Table, TableRow, TableCell, WidthType, AlignmentType, HeadingLevel, BorderStyle, TableBorders} = require 'docx'
{Packer} = require 'docx'

# Build contact section - name and details on one line
buildContact = (contact) ->
  [
    new Paragraph
      children: [
        new TextRun
          text: contact.name
          bold: true
          size: 28  # 14pt = 28 half-points

        new TextRun
          text: "    "

        new TextRun
          text: contact.email
          size: 20  # 10pt = 20 half-points

        new TextRun
          text: " • "
          size: 20

        new TextRun
          text: contact.phone
          size: 20
      ]
  ]

# Build keywords table
buildKeywordsTable = (keywords) ->
  categories = Object.keys keywords
  numColumns = categories.length
  maxLength = Math.max (keywords[cat].length for cat in categories)...

  # Calculate column width dynamically: 9360 DXA total / number of columns
  columnWidth = Math.floor 9360 / numColumns

  # Header row: "A Few Of My Favorite ..."
  headerRow = new TableRow
    children: [
      new TableCell
        children: [
          new Paragraph
            text: 'A Few Of My Favorite ...'
            alignment: AlignmentType.CENTER
        ]
        columnSpan: numColumns
    ]

  # Category name row
  categoryRow = new TableRow
    children: categories.map (cat) ->
      new TableCell
        children: [
          new Paragraph
            children: [
              new TextRun
                text: cat
                bold: true
                italics: true
                size: 14  # 7pt = 14 half-points
            ]
            alignment: AlignmentType.CENTER
        ]

  # Data rows
  dataRows = for i in [0...maxLength]
    new TableRow
      children: categories.map (cat) ->
        new TableCell
          children: [
            new Paragraph
              children: [
                new TextRun
                  text: keywords[cat][i] or ''
                  size: 14  # 7pt = 14 half-points
              ]
              alignment: AlignmentType.CENTER
          ]

  new Table
    rows: [headerRow, categoryRow].concat dataRows
    borders: TableBorders.NONE
    width:
      size: 0
      type: WidthType.AUTO  # Let the renderer figure out optimal column widths

# Build recursive list (for job deliverables)
buildList = (items, level = 0) ->
  result = []
  for item in items or []
    if typeof item is 'string'
      result.push new Paragraph
        text: "- #{item}"
        indent:
          left: level * 360  # 0.5 inch per level
    else
      result = result.concat buildList item, level + 1
  result

# Build a single position row for the positions table
buildPositionRow = (job) ->
  # Timeline column (reversed: to - from)
  timeline = []
  if job.from
    timeline.push new Paragraph
      text: job.to
      alignment: AlignmentType.RIGHT

    timeline.push new Paragraph
      text: "-"
      alignment: AlignmentType.CENTER

    timeline.push new Paragraph
      text: job.from
      alignment: AlignmentType.RIGHT

  # Job content column
  content = []

  content.push new Paragraph
    children: [
      new TextRun
        text: job.company
        bold: true
        size: 20  # 10pt = 20 half-points
    ]

  if job.group
    content.push new Paragraph
      children: [
        new TextRun
          text: job.group
          size: 18  # 9pt = 18 half-points
      ]

  if job.title
    content.push new Paragraph
      children: [
        new TextRun
          text: job.title
          italics: true
          size: 18  # 9pt = 18 half-points
      ]

  if job.summary
    content.push new Paragraph
      text: ""  # Spacing

    content.push new Paragraph
      children: [
        new TextRun
          text: job.summary
          size: 18  # 9pt = 18 half-points
      ]

  if job.delivered
    content.push new Paragraph
      text: ""  # Spacing before bullets

    content = content.concat buildList job.delivered

  new TableRow
    children: [
      new TableCell
        children: timeline
        width:
          size: 936   # 10% of 9360 DXA
          type: WidthType.DXA
        verticalAlign: 'top'

      new TableCell
        children: content
        width:
          size: 8424  # 90% of 9360 DXA
          type: WidthType.DXA
        verticalAlign: 'top'
    ]

# Build positions table (single table with all jobs)
buildPositionsTable = (positions) ->
  rows = positions.map (job) -> buildPositionRow job

  new Table
    rows: rows
    columnWidths: [936, 8424]  # 10% / 90% split
    borders: TableBorders.NONE
    width:
      size: 0
      type: WidthType.AUTO

# Main builder
module.exports = (resumé) ->
  {contact, intro, keywords, positions} = resumé

  children = []

  # Contact section
  children = children.concat buildContact contact
  children.push new Paragraph text: ''  # Spacing

  # Intro paragraph
  if intro
    children.push new Paragraph
      children: [
        new TextRun
          text: intro
          size: 18  # 9pt = 18 half-points
      ]
    children.push new Paragraph text: ''  # Spacing

  # Keywords table
  children.push buildKeywordsTable keywords
  children.push new Paragraph text: ''  # Spacing

  # Single positions table with all jobs
  children.push buildPositionsTable positions

  doc = new Document
    sections: [{children}]

  # Return promise that resolves to Buffer
  Packer.toBuffer doc
