#
# CoffeeLint tests.
#


path = require 'path'
fs = require 'fs'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffee-lint')


vows.describe('coffee-lint').addBatch({

    'has a version' : () ->
        assert.isString(coffeelint.VERSION)

    'tabs' :

        topic : () ->
            """
            x = () ->
            \treturn 1234
            """

        'can be forbidden' : (source) ->
            config = {tabs: false}
            errors = coffeelint.lint(source, config)
            error = errors[0]
            assert.isObject(error)
            assert.equal(error.line, 1)
            assert.equal(error.character, 0)
            assert.equal("Tabs are forbidden", error.reason)
            assert.equal("\treturn 1234", error.evidence)

        'can be permitted' : (source) ->
            config = {tabs: true}
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 0)

        'are forbidden by default' : (source) ->
            config = {}
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.equal(errors.length, 1)

        'are allowed in strings' : () ->
            source = "x = () -> '\t'"
            errors = coffeelint.lint(source, {tabs:false})
            assert.equal(errors.length, 0)

}).export(module)


