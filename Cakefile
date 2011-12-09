{spawn, exec} = require 'child_process'
fs = require('fs')
path = require('path')

SOURCE="src/coffeelint.coffee"
LIB_DIR="lib"
TEST_DIR="test"


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

glob = (dir, re) ->
    (path.join(dir, p) for p in fs.readdirSync(dir) when re.test(p))

# Lint our code.
lint = () ->
    paths = glob(TEST_DIR, /^test.*\.coffee$/)
    args = ['-f', 'test/fixtures/fourspaces.json'].concat(paths).concat(SOURCE)
    run 'bin/coffeelint', args

# Test our code
test = (callback) ->
    re = /^test.*\.coffee$/
    paths = glob(TEST_DIR, /^test.*\.coffee$/)
    run 'vows', paths.concat('--spec'), () ->
        notify('tests passed')
        callback()

task 'compile', 'Compile the source.', () ->
  coffee(watch=false)

task 'watch', 'Watch the source for changes.', (callback) ->
  coffee(watch=true)

task 'test', 'Run the tests.', () ->
  coffee watch=false, test

task 'lint', 'Lint the linter', () ->
    lint()

task 'dist', 'Create a distribution', () ->
    coffee watch=false, () ->
        test () ->
            lint()



