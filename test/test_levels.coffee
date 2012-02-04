path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

vows.describe('levels').addBatch({

    'CoffeeLint' :

        topic : "abc = 123;",

        'can ignore errors' : (source) ->
            config =
                no_trailing_semicolons : {level: 'ignore'}
            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors)

        'can return warnings' : (source) ->
            config =
                no_trailing_semicolons : {level: 'warn'}
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 1)
            error = errors[0]
            assert.equal(error.level, 'warn')

        'can return errors' : (source) ->
            config =
                no_trailing_semicolons : {level: 'error'}
            errors = coffeelint.lint(source, config)
            assert.isArray(errors)
            assert.lengthOf(errors, 1)
            error = errors[0]
            assert.equal(error.level, 'error')

        'catches unknown levels' : (source) ->

            config =
                no_trailing_semicolons : {level: 'foobar'}
            assert.throws () ->
                coffeelint.lint(source, config)


}).export(module)
