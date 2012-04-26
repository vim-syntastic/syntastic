path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

vows.describe('parens').addBatch({

    'Implicit parens' :

        topic : () ->
            '''
            console.log 'implict parens'
            blah = (a, b) ->
            blah 'a', 'b'
            '''

        'are allowed by default' : (source) ->
            errors = coffeelint.lint(source)
            assert.isArray(errors)
            assert.isEmpty(errors)

        'can be forbidden' : (source) ->
            config = {no_implicit_parens : {level:'error'}}
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 2)
            error = errors[0]
            assert.equal(error.lineNumber, 1)
            assert.equal(error.message, 'Implicit parens are forbidden')
            assert.equal(error.rule, 'no_implicit_parens')

}).export(module)
