#
# CoffeeLint tests.
#


path = require 'path'
fs = require 'fs'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')


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
}).export(module)
