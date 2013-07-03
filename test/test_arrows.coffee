path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

vows.describe('arrows').addBatch({

    'No spacing around the arrow operator' :

        topic : ->
            '''
            test1 = (foo, bar)->console.log("foobar")
            test2 = (foo, bar) ->console.log("foo->bar")
            test3 = (foo, bar)-> console.log("foo->bar")
            test4 = (foo, bar)->
              console.log("foo->bar")
            test5 = (foo, bar) ->
              console.log("foo->bar")
            '''

        'will return an error' : (source) ->
            config = {
                "indentation"  : { "value": 2, "level": "error" }
                "arrow_spacing": { "level": "error"}
            }
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 4)
            assert.equal(errors[0].lineNumber, 1)
            assert.equal(errors[1].lineNumber, 2)
            assert.equal(errors[2].lineNumber, 3)
            assert.equal(errors[3].lineNumber, 4)

        'will be ignored (no error)' : (source) ->
            config = { "arrow_spacing": { "level": "ignore" } }
            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors)

    'Handles good spacing when parentheses are generated' :

        topic : ->
            '''
            testingThis
              .around ->
                -> 4

            testingThis
              .around ->
                4

            testingThis
              .around -> 4

            testingThis =
              -> 5

            testingThis.around (a, b) ->
              -> "4"

            '''

        'when spacing is not required around arrow operator' : (source) ->
            config = {
                "indentation": { "value": 2, "level": "error" },
                "arrow_spacing": { "level": "ignore" }
            }
            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors)

        'when spacing is required around arrow operator' : (source) ->
            config = {
                "indentation": { "value": 2, "level": "error" },
                "arrow_spacing": { "level": "error" }
            }
            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors)

    'Handles bad spacing when parentheses are generated' :

        topic : ->
            '''
            testingThis
              .around ->
                ->4

            testingThis
              .around ->4

            testingThis =
              ->5

            testingThis.around (a, b) ->
              ->"4"

            testingThis ->-> "X"

            testingThis ->->"X"
            '''

        'when spacing is required around arrow operator' : (source) ->
            config = { "arrow_spacing": { "level": "error" } }
            errors = coffeelint.lint(source, config)
            assert.equal(errors[0].lineNumber, 3)
            assert.equal(errors[1].lineNumber, 6)
            assert.equal(errors[2].lineNumber, 9)
            assert.equal(errors[3].lineNumber, 12)
            assert.equal(errors[4].lineNumber, 14)
            assert.equal(errors[5].lineNumber, 16)
            assert.equal(errors[6].lineNumber, 16)
            assert.equal(errors.length, 7)

        'when spacing is not required around arrow operator' : (source) ->
            config = { "arrow_spacing": { "level": "ignore" } }
            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors)

    'Ignore spacing for non-generated parentheses' :
        # if the function has no parameters (and thus no parentheses),
        # it will accept a lack of spacing preceding the arrow (first example)
        topic : ->
            '''
            x(-> 3)
            x( -> 3)
            x((a,b) -> c)
            (-> true)()
            '''
        'when spacing is required around arrow operator' : (source) ->
            config = { "arrow_spacing": { "level": "error" } }
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 0)

        'when spacing is not required around arrow operator' : (source) ->
            config = { "arrow_spacing": { "level": "ignore" } }
            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors, 0)

    'Handle an arrow at beginning of statement' :
        topic : ->
            '''
            @waitForSelector ".application",
              -> @test.pass "homepage loaded ok"
              -> @test.fail "homepage didn't load"
              2000
            '''

        'when spacing is required around arrow operator' : (source) ->
            config = { "arrow_spacing": { "level": "error" } }
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 0)

        'when spacing is not required around arrow operator' : (source) ->
            config = { "arrow_spacing": { "level": "ignore" } }
            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors, 0)

}).export(module)