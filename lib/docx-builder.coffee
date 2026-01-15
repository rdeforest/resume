{Document, Paragraph, TextRun, Table, TableRow, TableCell, WidthType, AlignmentType, HeadingLevel, BorderStyle, TableBorders} = require 'docx'
{Packer} = require 'docx'

# Build contact column (name, email, phone on separate lines)
buildContactColumn = (contact) ->
  [
    new Paragraph
      children: [
        new TextRun
          text: contact.name
          bold: true
          size: 24  # 12pt = 24 half-points
          font: 'FreeSans'
      ]

    new Paragraph
      children: [
        new TextRun
          text: contact.email
          size: 18  # 9pt = 18 half-points
          font: 'FreeSans'
      ]

    new Paragraph
      children: [
        new TextRun
          text: contact.phone
          size: 18  # 9pt = 18 half-points
          font: 'FreeSans'
      ]
  ]

# Build intro column
buildIntroColumn = (intro) ->
  if intro
    [
      new Paragraph
        children: [
          new TextRun
            text: intro
            size: 18  # 9pt = 18 half-points
            font: 'FreeSans'
        ]
    ]
  else
    []

# Build header table with 3 columns: contact | intro | keywords
buildHeaderTable = (contact, intro, keywords) ->
  new Table
    rows: [
      new TableRow
        children: [
          new TableCell
            children: buildContactColumn contact
            width:
              size: 2175
              type: WidthType.DXA
            verticalAlign: 'top'

          new TableCell
            children: buildIntroColumn intro
            width:
              size: 2968
              type: WidthType.DXA
            verticalAlign: 'top'

          new TableCell
            children: [buildKeywordsTable keywords]
            width:
              size: 3878
              type: WidthType.DXA
            verticalAlign: 'top'
        ]
    ]
    columnWidths: [2175, 2968, 3878]
    borders: TableBorders.NONE
    width:
      size: 9021  # Narrower to fit in default margins
      type: WidthType.DXA

# Build keywords table
buildKeywordsTable = (keywords) ->
  categories = Object.keys keywords
  numColumns = categories.length
  maxLength = Math.max (keywords[cat].length for cat in categories)...

  # Specific column widths from user's edited version
  columnWidths = [1093, 900, 1082, 718]

  # Header row: "A Few Of My Favorite ..."
  headerRow = new TableRow
    children: [
      new TableCell
        children: [
          new Paragraph
            children: [
              new TextRun
                text: 'A Few Of My Favorite ...'
                size: 14  # 7pt = 14 half-points
                font: 'FreeSans'
            ]
            alignment: AlignmentType.LEFT
        ]
        columnSpan: numColumns
        verticalAlign: 'center'
    ]

  # Category name row
  categoryRow = new TableRow
    children: categories.map (cat, idx) ->
      new TableCell
        children: [
          new Paragraph
            children: [
              new TextRun
                text: cat
                bold: true
                italics: true
                size: 12  # 6pt = 12 half-points
                font: 'FreeSans'
            ]
            alignment: AlignmentType.LEFT
        ]
        width:
          size: columnWidths[idx]
          type: WidthType.DXA
        verticalAlign: 'center'

  # Data rows
  dataRows = for i in [0...maxLength]
    new TableRow
      children: categories.map (cat, idx) ->
        text = keywords[cat][i] or ''
        new TableCell
          children: [
            new Paragraph
              children: if text
                [
                  new TextRun
                    text: text
                    size: 12  # 6pt = 12 half-points
                    font: 'FreeSans'
                ]
              else
                []  # Empty array for empty cells to avoid extra height
              alignment: AlignmentType.LEFT
              spacing:
                after: 0
                before: 0
          ]
          width:
            size: columnWidths[idx]
            type: WidthType.DXA
          verticalAlign: 'center'

  new Table
    rows: [headerRow, categoryRow].concat dataRows
    columnWidths: columnWidths
    borders: TableBorders.NONE
    width:
      size: 3878  # Match parent cell width
      type: WidthType.DXA

# Build recursive list (for job deliverables)
# Just use simple hyphens for now since docx bullets aren't working
buildList = (items, level = 0) ->
  result = []
  indent_base = 180  # Smaller indent for compact look
  for item in items or []
    if typeof item is 'string'
      # Use hyphen prefix instead of bullets
      prefix = if level is 0 then '- ' else '  - '
      result.push new Paragraph
        children: [
          new TextRun
            text: "#{prefix}#{item}"
            size: 14  # 7pt = 14 half-points
            font: 'FreeSans'
        ]
        spacing:
          before: 0
          after: 0
          line: 240  # 1.0 line spacing (240 = 100%)
        indent:
          left: level * indent_base
    else
      result = result.concat buildList item, level + 1
  result

# Build a single position row for the positions table (3 columns)
buildPositionRow = (job) ->
  # Timeline column (reversed: to - from, centered)
  timeline = []
  if job.from
    timeline.push new Paragraph
      children: [
        new TextRun
          text: job.to
          size: 18  # 9pt = 18 half-points
          font: 'FreeSans'
      ]
      alignment: AlignmentType.CENTER

    timeline.push new Paragraph
      children: [
        new TextRun
          text: "to"
          size: 18  # 9pt = 18 half-points
          font: 'FreeSans'
      ]
      alignment: AlignmentType.CENTER

    timeline.push new Paragraph
      children: [
        new TextRun
          text: job.from
          size: 18  # 9pt = 18 half-points
          font: 'FreeSans'
      ]
      alignment: AlignmentType.CENTER

  # Job header column (company, group, title)
  header = []

  header.push new Paragraph
    children: [
      new TextRun
        text: job.company
        bold: true
        size: 20  # 10pt = 20 half-points
        font: 'FreeSans'
    ]

  if job.group
    header.push new Paragraph
      children: [
        new TextRun
          text: job.group
          size: 18  # 9pt = 18 half-points
          font: 'FreeSans'
      ]

  if job.title
    header.push new Paragraph
      children: [
        new TextRun
          text: job.title
          italics: true
          size: 18  # 9pt = 18 half-points
          font: 'FreeSans'
      ]

  # Job content column (summary and delivered)
  content = []

  if job.summary
    content.push new Paragraph
      children: [
        new TextRun
          text: job.summary
          size: 14  # 7pt = 14 half-points
          font: 'FreeSans'
      ]

  if job.delivered
    if job.summary
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
        children: header
        width:
          size: 2340  # 25% of 9360 DXA
          type: WidthType.DXA
        verticalAlign: 'top'

      new TableCell
        children: content
        width:
          size: 5745
          type: WidthType.DXA
        verticalAlign: 'top'
    ]

# Build positions table (single table with all jobs)
buildPositionsTable = (positions) ->
  rows = positions.map (job) -> buildPositionRow job

  new Table
    rows: rows
    columnWidths: [936, 2340, 5745]
    borders: TableBorders.NONE
    width:
      size: 9021  # Narrower to fit in default margins
      type: WidthType.DXA

# Main builder
module.exports = (resumé) ->
  {contact, intro, keywords, positions} = resumé

  children = []

  # Header table with contact | intro | keywords
  children.push buildHeaderTable contact, intro, keywords
  children.push new Paragraph text: ''  # Spacing

  # Single positions table with all jobs
  children.push buildPositionsTable positions

  doc = new Document
    sections: [{children}]

  # Return promise that resolves to Buffer
  Packer.toBuffer doc
