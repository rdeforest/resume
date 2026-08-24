# Resumé of Robert de Forest

This is my resumé and how I maintain it. It is intended to both document and
demonstrate some of my skills. It does not (yet) demonstrate my System
Engineering as doing so would will take a lot more time. Watch this space for
updates?

# How to use it

If you just want to read it: <https://defore.st/resume/>

Or download a copy:
- [PDF](https://defore.st/resume/resume.pdf)
- [DOCX](https://defore.st/resume/resume.docx)
- [JSON](https://defore.st/resume/resume.json)
- [YAML](https://defore.st/resume/resume.yaml)

If you want to tinker with it:

- Clone this repo
- Edit config.yaml and the contents of data/ to suit your purpose.
- Run `npm install`
- Run `cake run`

The results are available at http://localhost:3000

## Commands

Flags come *before* the task name — `cake -w regen`, not `cake regen -w`.

| Command | What it does |
| --- | --- |
| `cake run` | Serve on localhost:3000 |
| `cake regen` | Write every format into `public/` |
| `cake test` | Run the test suite |
| `cake -n deploy` | Show what deploying would upload |
| `cake deploy` | Publish to S3 and invalidate CloudFront |

Add `-w` to `run`, `regen`, or `test` to re-run on file changes.

# Upcoming work

- Collapse whitespace in the DOCX builder the way the PDF builder does
- Decide whether HTML should be generated directly too, or stay on pug
- Add more formats
  - Markdown
  - LaTeX?
- Improve quality of project
  - Create Yoman template as another project and derive this one from that one?
  - Remove references to "resumé" in code.
    - There's nothing resumé-specific about the code.
- Include all available styles and projects in the "UI".
- Port to
  - AWS?
  - Google Gears?
  - NW.js?
  - Electron?
  - Docker?
