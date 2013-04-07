path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')


vows.describe('linelength').addBatch({

    'Duplicate Keys' :

        topic : """
        class SomeThing
          getConfig: ->
            one = 1
            one = 5
            @config =
              keyA: one
              keyB: one
              keyA: 2
          getConfig: ->
            @config =
              foo: 1

          @getConfig: ->
            config =
              foo: 1
        """

        'should error by default' : (source) ->
            # Moved to a variable to avoid lines being too long.
            message = "Duplicate key defined in object or class"
            errors = coffeelint.lint(source)
            # Verify the two actual duplicate keys are found and it is not
            # mistaking @getConfig as a duplicate key
            assert.equal(errors.length, 2)
            error = errors[0]
            assert.equal(error.lineNumber, 8) # 2nd getA
            assert.equal(error.message, message)
            assert.equal(error.rule, 'duplicate_key')
            error = errors[1]
            assert.equal(error.lineNumber, 9) # 2nd getConfig
            assert.equal(error.message, message)
            assert.equal(error.rule, 'duplicate_key')

        'is optional' : (source) ->
            for length in [null, 0, false]
                config =
                    duplicate_key :
                        level: 'ignore'
                errors = coffeelint.lint(source, config)
                assert.isEmpty(errors)

}).export(module)

