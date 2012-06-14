path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

vows.describe('braces').addBatch({

    'Implicit braces' :

        topic : () ->
            '''
            a = 1:2
            y =
              'a':'b'
              3:4
            '''

        'are allowed by default' : (source) ->
            errors = coffeelint.lint(source)
            assert.isArray(errors)
            assert.isEmpty(errors)

        'can be forbidden' : (source) ->
            config = {no_implicit_braces : {level:'error'}}
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 2)
            error = errors[0]
            assert.equal(error.lineNumber, 1)
            assert.equal(error.message, 'Implicit braces are forbidden')
            assert.equal(error.rule, 'no_implicit_braces')

    'Implicit braces in class definitions' :

        topic : () ->
            '''
            class Animal
              walk: ->

            class Wolf extends Animal
              howl: ->

            class nested.Name
              constructor: (@options) ->

            class deeply.nested.Name
              constructor: (@options) ->

            x = class
              m : -> 123

            y = class extends x
              m : -> 456

            z = class

            r = class then 1:2
            '''

        'are always ignored' : (source) ->
            config = {no_implicit_braces : {level:'error'}}
            errors = coffeelint.lint(source)
            assert.isArray(errors)
            assert.isEmpty(errors)

}).export(module)
