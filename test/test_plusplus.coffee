path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')


vows.describe('plusplus').addBatch({

    'The increment and decrement operators' :

        topic : '''
            y++
            ++y
            x--
            --x
            '''

        'are permitted by default' : (source) ->
            errors = coffeelint.lint(source)
            assert.isArray(errors)
            assert.isEmpty(errors)

        'can be forbidden' : (source) ->
            errors = coffeelint.lint(source, {no_plusplus: {'level':'error'}})
            assert.isArray(errors)
            assert.lengthOf(errors, 4)
            error = errors[0]
            assert.equal(error.lineNumber, 1)
            assert.equal(error.rule, 'no_plusplus')

}).export(module)
