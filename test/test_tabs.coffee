#
# Tab tests.
#


path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')


vows.describe('tabs').addBatch({

    'Tabs' :

        topic : () ->
            """
            x = () ->
            \ty = () ->
            \t\treturn 1234
            """

        'can be forbidden' : (source) ->
            config = {}
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 4)
            error = errors[1]
            assert.equal(error.lineNumber, 2)
            assert.equal("Line contains tab indentation", error.message)
            assert.equal(error.rule, 'no_tabs')

        'can be permitted' : (source) ->
            config =
                no_tabs : {level: 'ignore'}
                indentation : {level: 'error', value: 1}
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 0)

        'are forbidden by default' : (source) ->
            config =
                indentation : {level: 'error', value: 1}
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.equal(errors.length, 2)

        'are allowed in strings' : () ->
            source = "x = () -> '\t'"
            errors = coffeelint.lint(source)
            assert.equal(errors.length, 0)

    'Tabs in multi-line strings' :

        topic : '''
            x = 1234
            y = """
            \t\tasdf
            """
            '''

        'are ignored' : (errors) ->
            errors = coffeelint.lint(errors)
            assert.isEmpty(errors)

    'Tabs in Heredocs' :

        topic : '''
            ###
            \t\tMy Heredoc
            ###
            '''

        'are ignored' : (errors) ->
            errors = coffeelint.lint(errors)
            assert.isEmpty(errors)

    'Tabs in multi line regular expressions' :

        topic : '''
            ///
            \t\tMy Heredoc
            ///
            '''

        'are ignored' : (errors) ->
            errors = coffeelint.lint(errors)
            assert.isEmpty(errors)


}).export(module)
