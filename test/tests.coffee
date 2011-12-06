#
# CoffeeLint tests.
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


vows.describe('coffeelint').addBatch({

    'has a version' : () ->
        assert.isString(coffeelint.VERSION)

    'tabs' :

        topic : () ->
            """
            x = () ->
            \ty = () ->
              \treturn 1234
            """

        'can be forbidden' : (source) ->
            config = {tabs: false}
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 2)
            error = errors[0]
            assert.equal(error.line, 1)
            assert.equal(error.character, 0)
            assert.equal("Tabs are forbidden", error.reason)
            assert.equal("\ty = () ->", error.evidence)

        'can be permitted' : (source) ->
            config = {tabs: true}
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 0)

        'are forbidden by default' : (source) ->
            config = {}
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.equal(errors.length, 2)

        'are allowed in strings' : () ->
            source = "x = () -> '\t'"
            errors = coffeelint.lint(source, {tabs: false})
            assert.equal(errors.length, 0)

    'trailing whitespace' :
        topic : () ->
            "x = 1234      \ny = 1"

        'can be forbidden' : (source) ->
            config = {trailing: false}
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 1)
            error = errors[0]
            assert.isObject(error)
            assert.equal(error.line, 0)
            assert.equal(error.character, 14)
            assert.equal("Contains trailing whitespace", error.reason)
            assert.equal("x = 1234      ", error.evidence)

        'can be permitted' : (source) ->
            config = {trailing: true}
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 0)

        'is forbidden by default' : (source) ->
            config = {}
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 1)

        'means tabs are forbidden too' : () ->
            source = "x = 1234\t"
            errors = coffeelint.lint(source, {})
            assert.equal(errors.length, 1)

    'maximum line length' :
        topic : () ->
            line = (length) ->
                return new Array(length + 1).join('-')
            lengths = [50, 79, 80, 81, 100, 200]
            (line(l) for l in lengths).join("\n")

        'defaults to 80' : (source) ->
            errors = coffeelint.lint(source)
            assert.equal(errors.length, 3)
            error = errors[0]
            assert.equal(error.line, 3)
            assert.equal(error.reason, "Maximum line length exceeded")

        'is configurable' : (source) ->
            errors = coffeelint.lint(source, {lineLength: 99})
            assert.equal(errors.length, 2)

        'is optional' : (source) ->
            for length in [null, 0, false]
                errors = coffeelint.lint(source, {lineLength: length})
                assert.isEmpty(errors)

    'command line' :

        'no args' :

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


}).export(module)
