path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')


vows.describe('indent').addBatch({

    'Indentation' :

        topic : () ->
            """
            x = () ->
              'two spaces'

            a = () ->
                'four spaces'
            """

        'defaults to two spaces' : (source) ->
            errors = coffeelint.lint(source)
            assert.equal(errors.length, 1)
            error = errors[0]
            assert.equal(error.reason, 'Line contains inconsistent indentation')
            assert.include(error.evidence, 'four spaces')
            assert.equal(error.rule, 'indentation')
            assert.equal(error.line, 4)

        'can be overridden' : (source) ->
            errors = coffeelint.lint(source, {indent:4})
            assert.equal(errors.length, 1)
            error = errors[0]
            assert.include(error.evidence, 'two spaces')
            assert.equal(error.line, 1)

        'is optional' : (source) ->
            errors = coffeelint.lint(source, {indent:false})
            assert.equal(errors.length, 0)

    'Nested indentation errors' :

        topic : () ->
            """
            x = () ->
              y = () ->
                  1234
            """

        'are caught' : (source) ->
            errors = coffeelint.lint(source)
            assert.lengthOf(errors, 1)
            error = errors[0]
            assert.equal(error.line, 2)

    'Compiler generated indentation' :

        topic : () ->
            """
            () ->
                if 1 then 2 else 3
            """

        'is ignored when not using two spaces' : (source) ->
            errors = coffeelint.lint(source, {indent: 4})
            assert.isEmpty(errors)

    'Indentation inside interpolation' :

        topic : 'a = "#{ 1234 }"'

        'is ignored' : (source) ->
            errors = coffeelint.lint(source)
            assert.isEmpty(errors)

    'Indentation in multi-line expressions' :

        topic : """
        x = '1234' + '1234' + '1234' +
                '1234' + '1234'
        """

        'is ignored' : (source) ->
            errors = coffeelint.lint(source)
            assert.isEmpty(errors)

}).export(module)
