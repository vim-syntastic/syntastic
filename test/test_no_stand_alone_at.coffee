path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

vows.describe('stand alone @').addBatch({

    'Stand alone @' :

        topic : () ->
            """
            @alright
            @   .error
            @ok()
            @ notok
            @[ok]
            @.ok
            not(@).ok
            @::ok
            @:: #notok
            """

        'are allowed by default' : (source) ->
            errors = coffeelint.lint(source)
            assert.isArray(errors)
            assert.isEmpty(errors)

        'can be forbidden' : (source) ->
            config = {no_stand_alone_at : {level:'error'}}
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 4)
            error = errors[0]
            assert.equal(error.lineNumber, 2)
            assert.equal(error.rule, 'no_stand_alone_at')
            error = errors[1]
            assert.equal(error.lineNumber, 4)
            assert.equal(error.rule, 'no_stand_alone_at')
            error = errors[2]
            assert.equal(error.lineNumber, 7)
            assert.equal(error.rule, 'no_stand_alone_at')
            error = errors[3]
            assert.equal(error.lineNumber, 9)
            assert.equal(error.rule, 'no_stand_alone_at')

}).export(module)
