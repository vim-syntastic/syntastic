path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

vows.describe('newparens').addBatch({

    'Missing Parentheses on "new"' :

        topic: () ->
            """
            class Foo

            # Warn about missing parens here
            a = new Foo
            # The parens make it clear no parameters are intended
            b = new Foo()
            c = new Foo 1, 2
            # Since this does have a parameter it should not require parens
            d = new Foo
              config: 'parameter'
            """

        'defaults to warning about missing parens': (source) ->
            config =
                empty_constructor_needs_parens:
                    level: 'error'
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 1)
            error = errors[0]
            assert.equal(error.lineNumber, 4)
            assert.equal(error.rule, 'empty_constructor_needs_parens')

}).export(module)
