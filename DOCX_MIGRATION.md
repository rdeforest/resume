# DOCX Migration Journey: A Development Story

## The Problem

The resume generator used `html-docx-js` to create DOCX files, but they appeared blank in LibreOffice and Google Docs. The library uses Microsoft's "altchunk" feature - an extension that embeds HTML directly into DOCX. While MS Word processes altchunks perfectly, LibreOffice and Google Docs simply ignore them, resulting in blank documents.

**Goal:** Generate DOCX files with proper formatting that work in all major document viewers.

## Approach 1: Drop-in Replacement (html-to-docx)

**Hypothesis:** Maybe another HTML-to-DOCX library would work better.

**Attempt:** Researched alternatives and found `html-to-docx`, which claims better compatibility.

**Result:** Would likely have same issues - most HTML-to-DOCX libraries use similar approaches or have incomplete CSS support.

**Learning:** Sometimes the problem isn't the specific library, it's the approach itself.

## Approach 2: Pandoc with HTML Input

**Hypothesis:** Use pandoc, a battle-tested universal document converter.

**Implementation:**
```coffeescript
htmlToDocx = (htmlContent) ->
  new Promise (resolve, reject) ->
    pandoc = spawn 'pandoc', ['-f', 'html', '-t', 'docx']
    # Stream HTML through pandoc's stdin/stdout
```

**Result:**
- ✅ DOCX files opened in all viewers
- ❌ Most formatting was missing - only newlines and unordered lists remained
- ❌ CSS styles weren't being converted to DOCX formatting

**Learning:** Pandoc's HTML parser focuses on semantic structure, not presentation. CSS → DOCX formatting conversion is limited.

## Approach 3: Table-Based Theme

**Hypothesis:** If CSS isn't working, use HTML structures that map directly to DOCX concepts.

**Implementation:**
- Created `data/themes/table-based/` with HTML tables instead of floats/flexbox
- Contact, keywords, and positions as separate table-based sections
- Semantic HTML structure: `<table>` with `<thead>`, `<tbody>`, proper column widths

**Result:**
- ✅ Structure carried through to DOCX
- ✅ Two-column job history layout worked
- ⚠️  Keywords table initially showed only 2 of 4 categories (display issue, all data present)
- ❌ Font sizes still ignored

**Learning:** Structural HTML (tables, lists, headings) converts reliably. Presentational CSS does not.

## Approach 4: Inline Styles

**Hypothesis:** Maybe inline styles would work where CSS classes don't.

**Implementation:**
```pug
table#categories(style="font-size: 7pt")
  thead
    tr
      th(style="font-size: 7pt; font-weight: bold")
```

**Result:**
- ❌ Pandoc still ignored font-size attributes
- ❌ All text rendered as 12pt Cambria in Google Docs

**Learning:** Pandoc's HTML parser doesn't process inline styles for DOCX output.

## Approach 5: Reference Document

**Hypothesis:** Use pandoc's `--reference-doc` to template the styling.

**Implementation:**
```coffeescript
args = ['-f', 'html', '-t', 'docx']
refDoc = path.resolve __dirname, '..', 'data', 'reference.docx'
if fs.existsSync refDoc
  args.push '--reference-doc', refDoc
```

**How it works:** Pandoc maps HTML elements to DOCX styles by semantic meaning:
- `<h1>` → "Heading 1" style
- `<td>` → "Table Contents" style
- `<p>` → "Normal" style

**Limitation:** Can't differentiate by class or id. All `<td>` elements get the same style, so you can't have one table with 7pt fonts and another with 12pt fonts.

**Result:**
- ✅ Could control some styling
- ❌ Not granular enough for our needs (different tables need different fonts)

**Learning:** Reference docs work for document-wide styling but can't handle element-specific presentation needs.

## Approach 6: Native DOCX Generation ("Worse is Better")

**Philosophy:** Instead of trying to convert HTML to DOCX, generate DOCX directly with explicit control.

**Implementation:**
Created `lib/docx-builder.coffee` (~160 lines) that explicitly constructs DOCX structure:

```coffeescript
buildKeywordsTable = (keywords) ->
  categories = Object.keys keywords

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
        ]
```

**Key functions:**
- `buildContact()` - Name, email, phone as paragraphs
- `buildKeywordsTable()` - Explicit 4-column table with exact font sizes
- `buildPositionTable()` - Two-column tables (23%/77% width split)
- `buildList()` - Recursive function for nested deliverables

**Result:**
- ✅ Full control over every formatting detail
- ✅ Font sizes work (14 half-points = 7pt)
- ✅ Table widths work (23%/77% percentage-based)
- ✅ All four keyword categories display properly
- ✅ Works in MS Word, LibreOffice, Google Docs

**Tradeoff:** Code duplication between Pug template and DOCX builder, but both are explicit and maintainable.

## What We Did Right

1. **Iterative refinement** - Each approach built on learnings from the previous
2. **Reality testing** - Verified actual behavior in target applications (Google Docs, LibreOffice)
3. **Structural verification** - Used `unzip -p` and `xmllint` to inspect DOCX XML structure
4. **Separated concerns** - Kept HTML/PDF generation independent from DOCX generation
5. **Accepted pragmatism** - "Worse is Better" when elegance has fundamental limitations

## What We Learned

### Technical Lessons

1. **CSS → DOCX is unreliable** - Pandoc's HTML parser focuses on semantic structure, not presentation
2. **Semantic HTML converts well** - Tables, lists, headings map cleanly to DOCX concepts
3. **Reference docs map by element type** - Can't differentiate `<td>` elements by class/id
4. **DOCX uses half-points for font sizes** - 7pt = size 14 in DOCX XML
5. **Percentage-based table widths work** - `<w:tcW w:type="pct" w:w="23%"/>`

### Philosophical Lessons

1. **Tool limitations are real** - Sometimes the elegant solution isn't possible with available tools
2. **Explicit beats clever** - 160 lines of explicit DOCX generation > fighting CSS conversion
3. **Different outputs have different needs** - HTML/PDF can share templates, DOCX needed its own approach
4. **"Worse is Better"** - Simple, explicit, working code beats elegant but broken abstractions
5. **Test in target environment** - What works in MS Word may not work in LibreOffice/Google Docs

## The Final Architecture

```
Resume Data (CoffeeScript)
    ↓
├── HTML (Pug → HTML → PDF)     # One path
└── DOCX (Native Builder)        # Different path
```

Both outputs use the same source data but different rendering approaches:
- **HTML/PDF:** Template-based (Pug → HTML → PDF via html-to-pdf-pup)
- **DOCX:** Programmatic (Direct construction via docx library)

This separation respects the different capabilities and limitations of each format.

## Key Takeaway

When converting between formats, understand what aspects transfer reliably:
- ✅ Semantic structure (headings, tables, lists)
- ⚠️  Layout hints (widths, alignment)
- ❌ Presentation details (fonts, colors, spacing)

For fine-grained presentation control, generate the format natively rather than converting.

## References

- [Worse is Better](https://www.dreamsongs.com/RiseOfWorseIsBetter.html) - Richard Gabriel
- [Pandoc HTML Reader](https://pandoc.org/MANUAL.html#readers)
- [Office Open XML (DOCX) Specification](http://officeopenxml.com/)
