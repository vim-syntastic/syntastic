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
            msg = 'Line contains inconsistent indentation'
            assert.equal(error.message, msg)
            assert.equal(error.rule, 'indentation')
            assert.equal(error.lineNumber, 5)
            assert.equal(error.context, "Expected 2 got 4")

        'can be overridden' : (source) ->
            config =
                indentation:
                    level: 'error'
                    value: 4
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 1)
            error = errors[0]
            assert.equal(error.lineNumber, 2)

        'is optional' : (source) ->
            config =
                indentation:
                    level: 'ignore'
                    value: 4
            errors = coffeelint.lint(source, config)
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
            assert.equal(error.lineNumber, 3)

    'Compiler generated indentation' :

        topic : () ->
            """
            () ->
                if 1 then 2 else 3
            """

        'is ignored when not using two spaces' : (source) ->
            config =
                indentation:
                    value: 4
            errors = coffeelint.lint(source, config)
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

    'Indentation across line breaks' :

        topic : () ->
            """
            days = ["mon", "tues", "wed",
                       "thurs", "fri"
                                "sat", "sun"]

            x = myReallyLongFunctionName =
                    1234

            arr = [() ->
                    1234
            ]
            """

        'is ignored' : (source) ->
            errors = coffeelint.lint(source)
            assert.isEmpty(errors)

    'Indentation on seperate line invocation' :

        topic : """
            rockinRockin
                    .around ->
                      3

            rockrockrock.
                    around ->
                      1234
            """

        'is ignored. Issue #4' : (source) ->
            errors = coffeelint.lint(source)
            assert.isEmpty(errors)

    'Indented chained invocations' :

        topic : """
            $('body')
                .addClass('k')
                .removeClass 'k'
                .animate()
                .hide()
            """

        'is permitted' : (source) ->
            assert.isEmpty(coffeelint.lint(source))

    'Ignore comment in indented chained invocations' :
        topic : () ->
            """
            test()
                .r((s) ->
                    # Ignore this comment
                    # Ignore this one too
                    # Ignore this one three
                    ab()
                    x()
                    y()
                )
                .s()
            """
        'no error when comment is in first line of a chain' : (source) ->
            config =
                indentation:
                    value: 4
            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors)

    'Ignore blank line in indented chained invocations' :
        topic : () ->
            """
            test()
                .r((s) ->


                    ab()
                    x()
                    y()
                )
                .s()
            """
        'no error when blank line is in first line of a chain' : (source) ->
            config =
                indentation:
                    value: 4
            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors)

    'Arbitrarily indented arguments' :

        topic : """
            myReallyLongFunction withLots,
                                 ofArguments,
                                 everywhere
            """

        'are permitted' : (source) ->
            errors = coffeelint.lint(source)
            assert.isEmpty(errors)

    'Indenting a callback in a chained call inside a function':

        topic: """
            someFunction = ->
              $.when(somePromise)
                .done (result) ->
                  foo = result.bar
            """
        'is permitted. See issue #88': (source) ->
            errors = coffeelint.lint(source)
            assert.isEmpty(errors)

}).export(module)
