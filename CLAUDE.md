# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A resume generation system built in CoffeeScript that converts structured data (YAML/JSON/CoffeeScript) into multiple output formats (HTML, PDF, DOCX). The system supports theming, live development with file watching, and serves resumes via an Express web server.

## Key Commands

**Flags go before the task name.** Cake's option parser only consumes switches
ahead of the task, so `cake regen -w` reads `-w` as a second task name and dies
with "No such task: -w" *after* the first task has already started.

### Development
```bash
cake run                    # Start HTTP server on localhost:3000
cake -w run                 # Start server with file watching
npm start                   # Alternative: start via npm (uses bin/www)
```

### Regeneration
```bash
cake regen                  # Regenerate every format into public/
cake -w regen               # Regenerate on file changes with watch mode
```

Writes `public/{project}.{html,pdf,docx,json,yaml}`. HTML goes through
`Project` (pug); the rest go through `lib/generate.coffee`, which renders each
converter in `lib/formats.coffee` and lands it with a tmp+rename.

### Testing
```bash
cake test                   # Run the suite
npm test                    # Same thing, without cake
cake -w test                # Re-run on change
```

Tests use node's built-in `node:test` runner (no test framework dependency),
written in CoffeeScript and loaded via `--require coffeescript/register`.

### Deployment
```bash
cake -n deploy              # Show what would be uploaded, change nothing
cake deploy                 # Upload to S3 and invalidate CloudFront
```

Reads the `deploy:` block in `config.yaml`. See "Deployment" below.

## Architecture

### Configuration System (lib/config.coffee)
- Loads `config.yaml` with defaults
- Derives paths from `project` and `theme` names:
  - `data/projects/{project}.coffee` - resume data
  - `data/themes/{theme}/main.pug` - template
  - `public/{project}.html` - output destination

### Data Layer
Resume data lives in `data/projects/` as CoffeeScript modules that:
- Export a function receiving builder utilities (`byCommaSpace`, `prevWithChanges`, `job`)
- Return structured resume data (contact, intro, keywords, positions)
- Use the `job()` function from lib/builder.coffee to track position changes

### Format Conversion (lib/formats.coffee)
Converters transform resume data into formats:
- **html**: Pug template rendering with config metadata
- **pdf**: Built directly from the data by `lib/pdf-builder.coffee` (pdfmake)
- **docx**: Built directly from the data by `lib/docx-builder.coffee` (docx)
- **yaml/json**: Direct serialization

All converters receive resume object and return converted output (possibly as Promise).

The visual formats no longer derive from HTML. Every HTML→X converter tried
(html-docx-js altchunks, pandoc, reference docs) lost the formatting that makes
the layout readable, and the two libraries doing the conversion went
unmaintained — `html-docx-js` first, then `html-to-pdf-pup`, which pulled in a
vulnerable `extract-zip`. Each visual format is now built from the résumé data
directly. `DOCX_MIGRATION.md` records the reasoning in full; it applies equally
to the PDF.

Both builders expose their intermediate document description for testing —
`pdf-builder.definition(resumé)` returns the pdfmake docDefinition, which is
what the tests assert against rather than the rendered bytes.

**Fonts:** the theme CSS and DOCX ask for FreeSans. The PDF uses PDFKit's
built-in Helvetica, which FreeSans is a metric clone of, so nothing has to be
embedded or shipped and the output matches on machines without FreeSans.

**Whitespace:** heredocs in the data keep their source line breaks, and blanked
fields arrive as whitespace-only strings (see `job()` below). `pdf-builder`'s
`prose()` collapses both, and absence is decided on the *collapsed* value —
testing the raw string treats `"      "` as present and emits an empty
paragraph. `docx-builder` does not yet do this.

### Project Regeneration (lib/project.coffee)
The `Project` class:
- Tracks source files (data + template) via SHA-256 hash
- `changed()` detects modifications by rehashing
- `refresh()` renders Pug template with data and atomically updates destination
- Used by both `tasks/regen.coffee` (standalone) and web routes (on-demand)

### Task System (lib/task.coffee)
Wrapper around CoffeeScript's Cakefile task/option:
- Tasks defined in `tasks/*.coffee` as modules exporting `(Task) -> new Task {...}`
- `Cakefile` loads every `*.coffee` in `tasks/`
- Options support defaults from environment variables or fallback values
- Tasks extend EventEmitter for lifecycle events

### Settings (lib/settings.coffee)
Shared by `regen` and `deploy`. Applies defaults, loads `config.yaml`, derives
the paths that weren't given, then resolves every path key against `ENVROOT`
so tasks work from any working directory.

### Web Server
- **Express app** (app.coffee): Sets up middleware, routes, error handling
- **Routes**:
  - `/` - Index page (routes/index.coffee)
  - `/resume/:format` - On-demand format conversion (routes/resume.coffee)
- **Formats**: Access resume as `/resume/html`, `/resume/pdf`, `/resume/docx`, etc.

### Development Utilities
- **lib/watcher.coffee**: File watching for auto-regeneration
- **lib/throbber.coffee**: CLI progress indicators (spinner, etc.)
- **lib/port.coffee**: Port handling with environment variable support
- **lib/util.coffee**: Utility functions for file operations and output

## Data Structure

Resume data file must export function receiving builder utilities:
```coffeescript
module.exports = ({byCommaSpace, job}) ->
  contact: {name, phone, email}
  intro: "..."
  keywords: {Modes, Languages, Technologies, Roles}
  positions: [
    job {company, group, title, from, to, summary, delivered}
    # ...more positions with job() tracking changes
  ]
```

`job()` is `prevWithChanges()`: any field a position doesn't mention is
inherited from the position before it. To *clear* an inherited field you must
say so explicitly — either `summary: undefined` (deletes it) or a
whitespace-only heredoc, which is what the data currently uses in three places.
Renderers therefore cannot treat a field's mere presence as meaningful.

## Theme Structure

Themes in `data/themes/{name}/`:
- `main.pug` - Pug template receiving resume data + config as locals
- Templates have access to: contact, intro, keywords, positions, updated, generated

## Deployment

The published résumé lives at <https://defore.st/resume/>.

```
defore.st (DNS)
  -> CloudFront distribution EEK3E034N69I5
       origin: defore.st.s3-website-us-west-2.amazonaws.com   <- website endpoint
  -> s3://defore.st/resume/
```

`cake deploy` uploads `public/{project}.html` as `resume/index.html`, uploads
the other formats under their own names, sets an explicit Content-Type on each
(S3 otherwise serves `application/octet-stream` and browsers download rather
than render), and invalidates `/resume/*`.

**Why the website endpoint matters.** The origin must be the bucket's *website*
endpoint (`...s3-website-us-west-2...`), not its REST endpoint
(`...s3.us-west-2...`). Only the website endpoint applies the bucket's
`IndexDocument`, which is what resolves a bare `/resume/` to `index.html` and
redirects `/resume` to `/resume/`. With the REST endpoint, CloudFront's
`DefaultRootObject` covers only `/`, so every subdirectory 403s. The
distribution was pointed at the REST endpoint until 2026-08-24; that was the
cause of `defore.st/resume` returning AccessDenied.

The bucket is public-read by policy and has no public-access block, which the
website endpoint requires (it can't use OAC/OAI). If you ever want the bucket
private, the origin has to go back to REST and a CloudFront Function must do
the `/` → `/index.html` rewrite instead.

## Known Issues

- `docx-builder` doesn't collapse whitespace the way `pdf-builder` does: heredoc
  newlines land literally inside `<w:t>` (harmless — OOXML normalizes them) and
  the three whitespace-only summaries each produce an empty paragraph (visible).
- `routes/resume.coffee` sets `Content-Disposition: attachment` for any format
  carrying a `type`, so adding a `type` to html/json/yaml there would turn them
  into downloads. That's why `tasks/deploy.coffee` keeps its own web types.
- `public/docx2.pdf` and `public/resume-edited.docx` are stray artifacts.
