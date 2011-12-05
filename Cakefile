{spawn, exec} = require 'child_process'

SOURCE="src/coffee-lint.coffee"
LIB_DIR="lib"

# Run the given command.
run = (command, args, callback) ->
  proc = spawn(command, args)
  proc.stdout.on 'data', (buffer) -> console.log buffer.toString()
  proc.stderr.on 'data', (buffer) -> console.log buffer.toString()
  proc.on        'exit', (status) ->
    process.exit(1) if status != 0
    cb() if typeof cb is 'function'


task 'compile', 'Compile the source.', (cb) ->
  run('coffee', ['-c', '-o', LIB_DIR, SOURCE], cb)

task 'watch', 'Watch the source for changes.', (cb) ->
  run('coffee', ['-w', '-c', '-o', LIB_DIR, SOURCE], cb)

task 'test', 'Run the tests.', (cb) ->
  run('vows', ['test'])
