{spawn, exec} = require 'child_process'


SOURCE="src/coffeelint.coffee"
LIB_DIR="lib"


# Run the given command.
run = (command, args, callback) ->
  proc = spawn(command, args)
  proc.stdout.on 'data', (buffer) -> console.log buffer.toString()
  proc.stderr.on 'data', (buffer) -> console.log buffer.toString()
  proc.on        'exit', (status) ->
    process.exit(1) if status != 0
    callback() if typeof callback is 'function'

notify = (message) ->
    line = new Array(message.length + 6).join('*')
    lines = [line, "* #{message}! *", line]
    (console.log(l) for l in lines)

coffee = (watch=false, callback) ->
  args = ['-w', '-c', '-o', LIB_DIR, SOURCE]
  args.shift() if not watch
  run('coffee', args, () ->
    notify('compiled')
    callback() if typeof callback is 'function'
  )

task 'compile', 'Compile the source.', () ->
  coffee(watch=false)

task 'watch', 'Watch the source for changes.', (callback) ->
  coffee(watch=true)

task 'test', 'Run the tests.', () ->
  coffee watch=false, () ->
    # FIXME: vows sucks on coffeescript, because it reports
    # the wrong line numbers. Compile first, then vows.
    run 'vows', ['test/tests.coffee', '--spec'], () ->
        notify('tests passed')
