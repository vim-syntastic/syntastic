path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')


vows.describe('coffelint').addBatch({

    'CoffeeLint' :

        topic : coffeelint.VERSION

        'has a version number' : (version) ->
            assert.isString(version)


}).export(module)
