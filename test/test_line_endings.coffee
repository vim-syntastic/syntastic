path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

vows.describe('line endings').addBatch({

    'Unix line endings' :

        topic : 'x = 1\ny=2'

        'are allowed by default' : (source) ->
            errors = coffeelint.lint(source)
            assert.isEmpty(errors)

        'can be forbidden' : (source) ->
            config = {line_endings : {level:'error', value:'windows'}}
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 1)
            error = errors[0]
            assert.equal(error.lineNumber, 1)
            assert.equal(error.message, 'Line contains incorrect line endings')
            assert.equal(error.context, 'Expected windows')
            assert.equal(error.rule, 'line_endings')

    'Windows line endings' :

        topic : 'x = 1\r\ny=2'

        'are allowed by default' : (source) ->
            errors = coffeelint.lint(source)
            assert.isEmpty(errors)

        'can be forbidden' : (source) ->
            config = {line_endings : {level:'error', value:'unix'}}
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 1)
            error = errors[0]
            assert.equal(error.lineNumber, 1)
            assert.equal(error.message, 'Line contains incorrect line endings')
            assert.equal(error.context, 'Expected unix')
            assert.equal(error.rule, 'line_endings')

    'Unknown line endings' :

        topic : 'x = 1\ny=2'

        'throw errors' : (source) ->
            config =
                line_endings : {level: 'error', value: 'osx'}
            assert.throws () ->
                coffeelint.lint(source, config)


}).export(module)
