path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

vows.describe('newparens').addBatch({

    'Missing Parentheses on "new"' :

        topic: () ->
            """
            class Foo

            a = new Foo
            b = new Foo()
            c = new Foo 1, 2
            """

        'defaults to warning about missing parens': (source) ->
            config =
                missing_new_parens:
                    level: 'error'
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 1)
            error = errors[0]
            assert.equal(error.lineNumber, 3)
            assert.equal(error.rule, 'missing_new_parens')

}).export(module)
