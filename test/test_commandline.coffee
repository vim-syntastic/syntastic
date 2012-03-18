#
# Tests for the command line tool.
#

path = require 'path'
fs = require 'fs'
vows = require 'vows'
assert = require 'assert'
{spawn, exec} = require 'child_process'
coffeelint = require path.join('..', 'lib', 'coffeelint')
coffeelint_path = path.join('bin', 'coffeelint')

# Run the coffeelint command line with the given
# args. Callback will be called with (error, stdout,
# stderr)
commandline = (args, callback) ->
    command = coffeelint_path
    exec("#{command} #{args.join(" ")}", callback)


vows.describe('commandline').addBatch({

    'with no args' :

        topic : () ->
            commandline([], this.callback)
            return undefined

        'shows usage' : (error, stdout, stderr) ->
            assert.isNotNull(error)
            assert.notEqual(error.code, 0)
            assert.include(stderr, "Usage")
            assert.isEmpty(stdout)

    'version' :
        topic : () ->
            commandline ["--version"], this.callback
            return undefined

        'exists' : (error, stdout, stderr) ->
            assert.isNull(error)
            assert.isEmpty(stderr)
            assert.isString(stdout)
            assert.include(stdout, coffeelint.VERSION)

    'with clean source' :

        topic : () ->
            commandline ["test/fixtures/clean.coffee"], this.callback
            return undefined

        'passes' : (error, stdout, stderr) ->
            assert.isNull(error)
            assert.include(stdout, 'Lint free!')
            assert.isEmpty(stderr)

    'with failing source' :

        topic : () ->
            commandline ["test/fixtures/fourspaces.coffee"], this.callback
            return undefined

        'works' : (error, stdout, stderr) ->
            assert.isNotNull(error)
            assert.isEmpty(stdout)
            assert.include(stderr.toLowerCase(), 'line')

    'with custom configuration' :

        topic : () ->
            args = [
                "-f"
                "test/fixtures/fourspaces.json"
                "test/fixtures/fourspaces.coffee"
            ]

            commandline args, this.callback
            return undefined

        'works' : (error, stdout, stderr) ->
            assert.isNull(error)

    'with multiple sources'  :

        topic : () ->
            args = [
                "-f"
                "test/fixtures/fourspaces.json"
                "test/fixtures/fourspaces.coffee"
                "test/fixtures/clean.coffee"
            ]

            commandline args, this.callback
            return undefined

        'works' : (error, stdout, stderr) ->
            assert.isNotNull(error)

    'with example configuration' :

        topic : () ->
            args = [
                "-f"
                "examples/coffeelint.json"
                "test/fixtures/clean.coffee"
            ]

            commandline args, this.callback
            return undefined

        'works' : (error, stdout, stderr) ->
            assert.isNull(error)

    'does not fail on warnings' :

        topic : () ->
            args = [
                "-f"
                "test/fixtures/twospaces.warning.json"
                "test/fixtures/fourspaces.coffee"
            ]

            commandline args, this.callback
            return undefined

        'works' : (error, stdout, stderr) ->
            assert.isNull(error)

    'with broken source' :

        topic : () ->
            args = ["test/fixtures/syntax_error.coffee"]
            commandline args, this.callback
            return undefined

        'fails' : (error, stdout, stderr) ->
            assert.isNotNull(error)


    'using stdin':

        'with working string':
            topic: () ->
                exec("echo somevariable = 1| #{coffeelint_path} --stdin", this.callback)
                return undefined

            'passes': (error, stdout, stderr) ->
                assert.isNull(error)
                assert.isEmpty(stderr)
                assert.isString(stdout)
                assert.include(stdout, 'Lint free!')

        'with failing string due to whitespace':
            topic: () ->
                exec("echo somevariable = 1 | #{coffeelint_path} --stdin", this.callback)
                return undefined

            'fails': (error, stdout, stderr) ->
                assert.isNotNull(error)
                assert.isEmpty(stdout)
                assert.isString(stderr)
                assert.isNotEmpty(stderr)
                assert.include(stderr, 'Line ends with trailing whitespace')

}).export(module)
