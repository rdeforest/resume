{spawn}      = require 'child_process'
fs           = require 'fs'
{basename}   = require 'path'

settings     = require '../lib/settings'
{formats}    = require '../lib/formats'
{outputPath} = require '../lib/generate'

# lib/formats only types the binary downloads, so the text formats need one
# here; without it S3 hands back application/octet-stream and browsers save
# index.html instead of rendering it.
webTypes =
  html: 'text/html; charset=utf-8'
  json: 'application/json'
  yaml: 'text/yaml; charset=utf-8'

typeFor = (name) -> formats[name].type ? webTypes[name]

# The website endpoint resolves a bare directory to index.html, so the rendered
# resumé is published under that name rather than resume.html.
remoteFor = (name, local) -> if name is 'html' then 'index.html' else basename local

run = (dryRun, command, args) ->
  console.log "  #{command} #{args.join ' '}"

  return Promise.resolve() if dryRun

  new Promise (resolved, rejected) ->
    spawn command, args, stdio: 'inherit'
      .on 'error', rejected
      .on 'exit',  (code) ->
        if code is 0
          resolved()
        else
          rejected new Error "#{command} exited #{code}"

module.exports = (Task) ->
  new Task
    deploy:
      description: 'Publish the generated resumé to S3 and invalidate CloudFront'

      start: (options) ->
        config = settings()
        {deploy, destination} = config
        dryRun = Boolean options['dry-run']

        unless deploy?.bucket
          console.error 'config.yaml needs a deploy: section naming a bucket'
          process.exit 1

        uploads = for name of formats
          ext   = formats[name].extension or name
          local = outputPath destination, ext
          {name, local, remote: remoteFor name, local}

        missing = uploads.filter ({local}) -> not fs.existsSync local

        if missing.length
          console.error 'Missing generated files -- run `cake regen` first:'
          console.error "  #{local}" for {local} in missing
          process.exit 1

        console.log "Publishing to s3://#{deploy.bucket}/#{deploy.prefix}/#{if dryRun then ' (dry run)' else ''}"

        uploads
          .reduce (chain, {local, remote, name}) ->
            chain.then -> run dryRun, 'aws', [
              's3', 'cp', local
              "s3://#{deploy.bucket}/#{deploy.prefix}/#{remote}"
              '--content-type',  typeFor name
              '--cache-control', deploy.cacheControl ? 'public, max-age=300'
            ]
          , Promise.resolve()

          .then ->
            return unless deploy.distribution

            run dryRun, 'aws', [
              'cloudfront', 'create-invalidation'
              '--distribution-id', deploy.distribution
              '--paths', "/#{deploy.prefix}/*"
            ]

          .then  -> console.log if dryRun then 'Dry run complete.' else 'Deployed.'
          .catch (e) ->
            console.error "Deploy failed: #{e.message}"
            process.exit 1
