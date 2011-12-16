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
            assert.equal(error.lineNumber, 3)
            assert.equal(error.message, "Line exceeds maximum allowed length")
            assert.equal(error.rule, 'max_line_length')

        'is configurable' : (source) ->
            config =
                max_line_length :
                    value: 99
                    level: 'error'
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 2)

        'is optional' : (source) ->
            for length in [null, 0, false]
                config =
                    max_line_length :
                        value: length
                        level: 'ignore'
                errors = coffeelint.lint(source, config)
                assert.isEmpty(errors)

}).export(module)
