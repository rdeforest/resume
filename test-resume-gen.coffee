#!/usr/bin/env coffee

# Quick script to generate resume.docx for testing
fs      = require 'fs'
path    = require 'path'

# Change to resume directory
resumeDir = '/mnt/nvme0n1p4/git/github/rdeforest/resume'
process.chdir resumeDir

# Load modules
Config = require './lib/config'
config = new Config
formats = require './lib/formats'
builder = require './lib/builder'

# Load resume data
dataPath = './data/projects/resume.coffee'
resumeModule = require dataPath
resumeData = resumeModule builder

# Generate DOCX
console.log 'Generating DOCX...'
docxBuilder = require './lib/docx-builder'
docxBuilder resumeData
  .then (buffer) ->
    outputPath = '/tmp/test-resume.docx'
    fs.writeFileSync outputPath, buffer
    console.log "Generated: #{outputPath}"
  .catch (err) ->
    console.error 'Error:', err
    process.exit 1
