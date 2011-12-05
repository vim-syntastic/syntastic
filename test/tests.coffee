#
# CoffeeLint tests.
#


path = require 'path'
fs = require 'fs'

vows = require 'vows'
assert = require 'assert'

coffeelint = require path.join('..', 'lib', 'coffee-lint')


vows.describe('coffee-lint').addBatch({

    'version' :

        'isDefined' : () ->
            assert.isString(coffeelint.VERSION)
    'another' : () ->
        assert.isString(1)

}).export(module)

