#
# Tests for the command line tool.
#

path = require 'path'
fs = require 'fs'
vows = require 'vows'
assert = require 'assert'
{spawn, exec} = require 'child_process'
coffeelint = require path.join('..', 'lib', 'coffeelint')


# Run the coffeelint command line with the given
# args. Callback will be called with (error, stdout,
# stderr)
commandline = (args, callback) ->
    command = path.join('bin', 'coffeelint')
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
            commandline ["test/fixtures/tabs.coffee"], this.callback
            return undefined

        'works' : (error, stdout, stderr) ->
            assert.isNotNull(error)
            assert.isEmpty(stdout)
            assert.include(stderr.toLowerCase(), 'error')

    'with custom configuration' :

        topic : () ->
            args = [
                "-f"
                "test/fixtures/tabs.json"
                "test/fixtures/tabs.coffee"
            ]

            commandline args, this.callback
            return undefined

        'works' : (error, stdout, stderr) ->
            assert.isNull(error)

}).export(module)
