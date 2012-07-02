path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

vows.describe('blockconfig').addBatch({

    'Disable statements' :

        topic : () ->
            """
            # coffeelint: disable=no_trailing_semicolons
            a 'you get a semi-colon';
            b 'you get a semi-colon';
            # coffeelint: enable=no_trailing_semicolons
            c 'everybody gets a semi-colon';
            """

        'can disable rules in your config' : (source) ->
            config =
                no_trailing_semicolons : {level: 'error'}
            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors)
###
    'Enable statements' :

        topic : () ->
            """
            # coffeelint: enable=no_implicit_braces
            a 'implicit braces here'
            b 'implicit braces', 'also here'
            # coffeelint: disable=no_implicit_braces
            c 'implicit braces allowed here'
            """

        'can enable rules not in your config' : (source) ->
            errors = coffeelint.lint(source)
            assert.equal(errors.length, 2)

    'Enable all statements' :
        topic : () ->
            """
            # coffeelint: disable=no_trailing_semicolons,no_implicit_braces
            a 'you get a semi-colon';
            b 'you get a semi-colon';
            # coffeelint: enable
            c 'everybody gets a semi-colon';
            """

        'will re-enable all rules in your config' : (source) ->
            config =
                no_implicit_braces : {level: 'error'}
                no_trailing_semicolons : {level: 'error'}
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 2)
###
}).export(module)