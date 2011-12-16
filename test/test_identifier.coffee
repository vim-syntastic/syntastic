path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')


vows.describe('identifiers').addBatch({

    'Camel cased class names' :

        topic : """
            class Animal

            class Wolf extends Animal

            class BurmesePython extends Animal

            class Band

            class ELO extends Band

            class Eiffel65 extends Band

            class nested.Name

            class deeply.nested.Name
            """

        'are valid by default' : (source) ->
            errors = coffeelint.lint(source)
            assert.isEmpty(errors)

    'Non camel case class names' :

        topic : """
            class animal

            class wolf extends Animal

            class Burmese_Python extends Animal

            class canadaGoose extends Animal
            """

        'are rejected by default' : (source) ->
            errors = coffeelint.lint(source)
            assert.lengthOf(errors, 4)
            error = errors[0]
            assert.equal(error.lineNumber, 1)
            assert.equal(error.message,  'Class names should be camel cased')
            assert.equal(error.context,  'class name: animal')
            assert.equal(error.rule,  'camel_case_classes')

        'can be permitted' : (source) ->
            config =
                camel_case_classes : {level : 'ignore'}
            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors)

}).export(module)
