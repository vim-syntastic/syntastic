path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')


# Return the cyclomatic complexity of a code snippet with one function.
getComplexity = (source) ->
    config = {cyclomatic_complexity : {level: 'error', value: 0}}
    errors = coffeelint.lint(source, config)
    assert.isNotEmpty(errors)
    assert.lengthOf(errors, 1)
    error = errors[0]
    assert.equal(error.rule, 'cyclomatic_complexity')
    return error.context


vows.describe('cyclomatic complexity').addBatch({


    'An empty function' :

        topic : getComplexity "x = () -> 1234"

        'has a complexity of one' : (complexity) ->
            assert.equal(complexity, 1)

    'If statement' :

        topic : getComplexity "x = () -> 2 if $ == true"

        'has a complexity of two' : (complexity) ->
            assert.equal(complexity, 2)

    'If Else statement' :

        topic : getComplexity 'y = -> if $ then 1 else 3'

        'has a complexity of two' : (complexity) ->
            assert.equal(complexity, 2)

    'If ElseIf statement' :

        topic : getComplexity """
            x = ->
              if 1233
                'abc'
              else if 456
                'xyz'
            """

        'has a complexity of three' : (complexity) ->
            assert.equal(complexity, 3)

    'If If-Else Else statement' :

        topic : getComplexity(
            """
            z = () ->
              if x
                1
              else if y
                2
              else
                3
            """)

        'has a complexity of three' : (complexity) ->
            assert.equal(complexity, 3)

    'Nested if statements' :

        topic : getComplexity(
            """
            z = () ->
              if abc?
                if other?
                  123
            """)

        'has a complexity of three' : (complexity) ->
            assert.equal(complexity, 3)

    'A while loop' :

        topic : getComplexity(
            """
            x = () ->
              while 1
                'asdf'
            """)

        'increments complexity' : (complexity) ->
            assert.equal(complexity, 2)

    'An until loop' :

        topic : getComplexity "x = () -> log 'a' until $?"

        'increments complexity' : (complexity) ->
            assert.equal(complexity, 2)

}).export(module)
