path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

vows.describe('newparens').addBatch({

    'Missing Parentheses on "new Foo"' :

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

        'warns about missing parens': (source) ->
            config =
                empty_constructor_needs_parens:
                    level: 'error'
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 1)
            error = errors[0]
            assert.equal(error.lineNumber, 4)
            assert.equal(error.rule, 'empty_constructor_needs_parens')

    'Missing Parentheses on "new Foo 1, 2"' :

        topic: () ->
            """
            class Foo

            a = new Foo
            b = new Foo()
            # Warn about missing parens here
            c = new Foo 1, 2
            d = new Foo
              config: 'parameter'
            # But not here
            e = new Foo(1, 2)
            f = new Foo(
              config: 'parameter'
            )
            """

        'warns about missing parens': (source) ->
            config =
                non_empty_constructor_needs_parens:
                    level: 'error'
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 2)
            assert.equal(errors[0].lineNumber, 6)
            assert.equal(errors[0].rule, 'non_empty_constructor_needs_parens')
            assert.equal(errors[1].lineNumber, 7)
            assert.equal(errors[1].rule, 'non_empty_constructor_needs_parens')

}).export(module)
