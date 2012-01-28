path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')


vows.describe('cyclomatic complexity').addBatch({

    'Cyclomatic Complexity' :

        topic : ->
            """
            x = () ->
              if $ == true
                if testing
                  1
              else if window is false
                y = () ->
                  1234
              else
                3
            """

        'can be enabled' : (source) ->
            config = {cyclomatic_complexity : {level: 'error', value: 4}}
            errors = coffeelint.lint(source)
            assert.isNotEmpty(errors)
            console.log errors

}).export(module)
