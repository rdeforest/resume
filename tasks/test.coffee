{spawn}   = require 'child_process'
{resolve} = require 'path'

envroot   = process.env.ENVROOT or resolve __dirname, '..'

# node:test discovers .coffee files fine when handed a glob; it just needs the
# CoffeeScript require hook in each worker, hence --require.
module.exports = (Task) ->
  new Task
    test:
      description: 'Run the test suite'

      start: (options) ->
        args = ['--require', 'coffeescript/register', '--test']
        args.push '--watch' if options.watch
        args.push 'test/**/*.test.coffee'

        spawn process.execPath, args, cwd: envroot, stdio: 'inherit'
          .on 'exit', (code) -> process.exit code ? 1
