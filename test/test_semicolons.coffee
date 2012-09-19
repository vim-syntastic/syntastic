path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')


vows.describe('semicolons').addBatch({

    'Semicolons at end of lines' :

        topic : () ->
            """
            x = 1234;
            y = 1234; z = 1234
            """

        'are forbidden' : (source) ->
            errors = coffeelint.lint(source)
            assert.lengthOf(errors, 1)
            error = errors[0]
            assert.equal(error.lineNumber, 1)
            assert.equal(error.message, "Line contains a trailing semicolon")
            assert.equal(error.rule, 'no_trailing_semicolons')

        'can be ignored' : (source) ->
            config =
                no_trailing_semicolons : {level: 'ignore'}
            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors)

    'Semicolons in multiline expressions' :

        topic : '''
            x = "asdf;
            asdf"

            y = """
            asdf;
            """

            z = ///
            a*\;
            ///
            '''

        'are ignored' : (source) ->
            errors = coffeelint.lint(source)
            assert.isEmpty(errors)

    'Semicolons with windows line endings' :

        topic : () ->
            "x = 1234;\r\n"

        'works as expected' : (source) ->
            config = {
                line_endings : {value : 'windows'}
            }
            errors = coffeelint.lint(source, config)
            assert.lengthOf(errors, 1)
            error = errors[0]
            assert.equal(error.lineNumber, 1)
            assert.equal(error.message, "Line contains a trailing semicolon")
            assert.equal(error.rule, 'no_trailing_semicolons')

}).export(module)
