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
            config = {tabs: false}
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 4)
            error = errors[1]
            assert.equal(error.line, 1)
            assert.equal(error.character, 0)
            assert.equal("Tabs are forbidden", error.reason)
            assert.equal("\ty = () ->", error.evidence)

        'can be permitted' : (source) ->
            config = {tabs: true}
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 0)

        'are forbidden by default' : (source) ->
            config = {indent: false}
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
