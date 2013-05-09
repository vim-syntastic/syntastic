path = require 'path'
vows = require 'vows'
assert = require 'assert'
CoffeeScript = require 'coffee-script'
CoffeeScript.old_tokens = CoffeeScript.tokens
CoffeeScript.tokens = (text) ->
    CoffeeScript.updated_tokens_called = true
    tokens = CoffeeScript.old_tokens(text)
    for token in tokens
        if typeof token[2] == "number"
            if token[0] == 'INDENT' or token[1] == 'OUTDENT'
                token[2] = {first_line: token[2] - 1, last_line: token[2]}
            else
                token[2] = {first_line: token[2], last_line: token[2]}
        token
coffeelint = require path.join('..', 'lib', 'coffeelint')


vows.describe("CoffeeScript 1.5.0+").addBatch({

    "lineNumber has become an object" :

        topic : () ->
            """
            x = 1234;
            y = 1234; z = 1234
            """

        'work with 1.5.0+ tokens' : (source) ->
            assert.isUndefined(CoffeeScript.updated_tokens_called)
            errors = coffeelint.lint(source)
            assert.isArray(errors)
            assert.lengthOf(errors, 1)
            assert.isTrue(CoffeeScript.updated_tokens_called)
            error = errors[0]
            assert.equal(error.lineNumber, 1)
            assert.equal(error.message, "Line contains a trailing semicolon")
            assert.equal(error.rule, 'no_trailing_semicolons')

    "for indentation last_line is the correct value for lineNumber" :
        
        topic : () ->
            """
            x = () ->
              'two spaces'

            a = () ->
                'four spaces'
            """

        'works with 1.5.0+' : (source) ->
            errors = coffeelint.lint(source)
            assert.equal(errors.length, 1)
            error = errors[0]
            msg = 'Line contains inconsistent indentation'
            assert.equal(error.message, msg)
            assert.equal(error.rule, 'indentation')
            assert.equal(error.lineNumber, 5)
            assert.equal(error.context, "Expected 2 got 4")

}).addBatch({

    "Cleanup" : () ->

        CoffeeScript.tokens = CoffeeScript.old_tokens
        delete CoffeeScript.old_tokens

}).export(module)
