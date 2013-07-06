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

    'Cyclomatic complexity' :

        topic : """
            x = ->
              1 and 2 and 3 and
              4 and 5 and 6 and
              7 and 8 and 9 and
              10 and 11
            """

        'defaults to ignore' : (source) ->
            errors = coffeelint.lint(source)
            assert.isArray(errors)
            assert.isEmpty(errors)

        'can be enabled' : (source) ->
            config = {cyclomatic_complexity : {level: 'error'}}
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 1)
            error = errors[0]
            assert.equal(error.rule, 'cyclomatic_complexity')
            assert.equal(error.context, 11)
            assert.equal(error.lineNumber, 1)
            assert.equal(error.lineNumberEnd, 5)

        'can be enabled with configurable complexity' : (source) ->
            config = {cyclomatic_complexity : {level: 'error', value: 12}}
            errors = coffeelint.lint(source)
            assert.isArray(errors)
            assert.isEmpty(errors)

    'An empty function' :

        topic : "x = () -> 1234"

        'has a complexity of one' : (source) ->
            complexity = getComplexity(source)
            assert.equal(complexity, 1)

    'If statement' :

        topic : "x = () -> 2 if $ == true"

        'increments the complexity' : (source) ->
            complexity = getComplexity(source)
            assert.equal(complexity, 2)


    'If Else statement' :

        topic : 'y = -> if $ then 1 else 3'

        'increments the complexity' : (source) ->
            complexity = getComplexity(source)
            assert.equal(complexity, 2)

    'If ElseIf statement' :

        topic : """
            x = ->
              if 1233
                'abc'
              else if 456
                'xyz'
            """

        'has a complexity of three' : (source) ->
            complexity = getComplexity(source)
            assert.equal(complexity, 3)

    'If If-Else Else statement' :

        topic : """
            z = () ->
              if x
                1
              else if y
                2
              else
                3
            """

        'has a complexity of three' : (source) ->
            complexity = getComplexity(source)
            assert.equal(complexity, 3)

    'Nested if statements' :

        topic : """
            z = () ->
              if abc?
                if other?
                  123
            """

        'has a complexity of three' : (source) ->
            complexity = getComplexity(source)
            assert.equal(complexity, 3)


    'A while loop' :

        topic : """
            x = () ->
              while 1
                'asdf'
            """

        'increments complexity' : (source) ->
            complexity = getComplexity(source)
            assert.equal(complexity, 2)

    'An until loop' :

        topic : "x = () -> log 'a' until $?"

        'increments complexity' : (source) ->
            complexity = getComplexity(source)
            assert.equal(complexity, 2)

    'A for loop' :

        topic : """
            x = () ->
              for i in window
                log i
            """

        'increments complexity' : (source) ->
            complexity = getComplexity(source)
            assert.equal(complexity, 2)

    'A list comprehension' :

        topic : "x = -> [a for a in window]"

        'increments complexity' : (source) ->
            complexity = getComplexity(source)
            assert.equal(complexity, 2)

    'Try / Catch blocks' :

        topic : """
            x = () ->
              try
                divide("byZero")
              catch error
                log("uh oh")
            """

        'increments complexity' : (source) ->
            assert.equal(getComplexity(source), 2)

    'Try / Catch / Finally blocks' :

        topic : """
            x = () ->
              try
                divide("byZero")
              catch error
                log("uh oh")
              finally
                clean()
            """

        'increments complexity' : (source) ->
            assert.equal(getComplexity(source), 2)

    'Switch statements without an else' :

        topic : '''
            x = () ->
              switch a
                when "b" then "b"
                when "c" then "c"
                when "d" then "d"
            '''

        'increase complexity by the number of cases' : (source) ->
            complexity = getComplexity(source)
            assert.equal(complexity, 4)

    'Switch statements with an else' :

        topic : '''
            x = () ->
              switch a
                when "b" then "b"
                when "c" then "c"
                when "d" then "d"
                else "e"
            '''

        'increase complexity by the number of cases' : (source) ->
            complexity = getComplexity(source)
            assert.equal(complexity, 4)

    'And operators' :

        topic : 'x = () -> $ and window'

        'increments the complexity' : (source) ->
            complexity = getComplexity(source)
            assert.equal(complexity, 2)

    'Or operators' :

        topic : 'x = () -> $ or window'

        'increments the complexity' : (source) ->
            complexity = getComplexity(source)
            assert.equal(complexity, 2)

    'A complicated example' :

        topic : """
            x = () ->
              if a and b and c or d and c or e
                if x or d or e of f
                  1
              else if window
                while 1 and 3
                  2
              while false
                y
              return false
            """

        'works' : (source) ->
            config = {cyclomatic_complexity : {level: 'error'}}
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 1)
            error = errors[0]
            assert.equal(error.rule, 'cyclomatic_complexity')
            assert.equal(error.lineNumber, 1)
            assert.equal(error.lineNumberEnd, 10)
            assert.equal(error.context, 14)

}).export(module)
