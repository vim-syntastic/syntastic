path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')


vows.describe('coffelint').addBatch({

    "CoffeeLint's version number" :

        topic : coffeelint.VERSION

        'exists' : (version) ->
            assert.isString(version)

    "CoffeeLint's errors" :

        topic : coffeelint.lint """
            a = () ->\t
                1234
            """

        'are sorted by line number' : (errors) ->
            assert.isArray(errors)
            assert.lengthOf(errors, 2)
            assert.equal(errors[1].lineNumber, 1)
            assert.equal(errors[0].lineNumber, 0)

}).export(module)
