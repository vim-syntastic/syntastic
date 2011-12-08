path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')


vows.describe('linelength').addBatch({

    'Maximum line length' :

        topic : () ->
            line = (length) ->
                return '"' + new Array(length - 1).join('-') + '"'
            lengths = [50, 79, 80, 81, 100, 200]
            (line(l) for l in lengths).join("\n")

        'defaults to 80' : (source) ->
            errors = coffeelint.lint(source)
            assert.equal(errors.length, 3)
            error = errors[0]
            assert.equal(error.line, 3)
            assert.equal(error.reason, "Maximum line length exceeded")

        'is configurable' : (source) ->
            errors = coffeelint.lint(source, {lineLength: 99})
            assert.equal(errors.length, 2)

        'is optional' : (source) ->
            for length in [null, 0, false]
                errors = coffeelint.lint(source, {lineLength: length})
                assert.isEmpty(errors)

}).export(module)
