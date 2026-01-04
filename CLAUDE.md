# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A resume generation system built in CoffeeScript that converts structured data (YAML/JSON/CoffeeScript) into multiple output formats (HTML, PDF, DOCX). The system supports theming, live development with file watching, and serves resumes via an Express web server.

## Key Commands

### Development
```bash
cake run                    # Start HTTP server on localhost:3000
cake run -w                 # Start server with file watching
npm start                   # Alternative: start via npm (uses bin/www)
```

### Regeneration
```bash
cake regen                  # Regenerate static HTML from data
cake regen -w               # Regenerate on file changes with watch mode
```

### Testing
```bash
cake test                   # Run tests (currently not implemented)
```

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
- **pdf**: HTML → PDF via html-to-pdf-pup
- **docx**: HTML → DOCX via html-docx-js
- **yaml/json**: Direct serialization

All converters receive resume object and return converted output (possibly as Promise).

### Project Regeneration (lib/project.coffee)
The `Project` class:
- Tracks source files (data + template) via SHA-256 hash
- `changed()` detects modifications by rehashing
- `refresh()` renders Pug template with data and atomically updates destination
- Used by both `tasks/regen.coffee` (standalone) and web routes (on-demand)

### Task System (lib/task.coffee)
Wrapper around CoffeeScript's Cakefile task/option:
- Tasks defined in `tasks/*.coffee` as modules exporting Task instances
- `Cakefile` loads tasks from `tasks/` directory (currently filtered to only load `run.coffee`)
- Options support defaults from environment variables or fallback values
- Tasks extend EventEmitter for lifecycle events

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

## Theme Structure

Themes in `data/themes/{name}/`:
- `main.pug` - Pug template receiving resume data + config as locals
- Templates have access to: contact, intro, keywords, positions, updated, generated

## Known Issues

- `cake regen` currently has issues (mentioned in README "Upcoming work")
- Cakefile filters tasks to only load `run.coffee` (line 19)
- Test task exists but is empty
