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
            token[2] = {first_line: token[2]}
        token
coffeelint = require path.join('..', 'lib', 'coffeelint')


vows.describe("CoffeeScript 1.5.0+").addBatch({

    "lineNumber" :

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

}).addBatch({

    "Cleanup" : () ->

        CoffeeScript.tokens = CoffeeScript.old_tokens
        delete CoffeeScript.old_tokens

}).export(module)
