path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')


vows.describe('newlines_after_classes').addBatch({
    
    'Classfile ends with end of class' :
    
        topic : () ->
            """
                class Foo
                    
                    constructor: () ->
                        bla()
                    
                    a: "b"
                    c: "d"
            """
        
        "won't match" : (source) ->
            config =
                newlines_after_classes:
                    level: 'error'
                    value: 3
                indentation:
                    level: 'ignore'
                    value: 4
            errors = coffeelint.lint(source, config)
            console.log errors
            assert.equal(errors.length, 0)
            
    
    ###
    'Class with arbitrary Code following' :
            
        topic : () ->
            """
            class Foo
                
                constructor: ( ) ->
                    bla()
                
                a: "b"
                c: "d"
            
            
            
            class Bar extends Foo
                
                constructor: ( ) ->
                    bla()
            """
        
        "defaults to ignore newlines_after_classes" : (source) ->
            config =
                indentation:
                    level: 'ignore'
                    value: 4
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 0)
        
        "has too few newlines after class" : (source) ->
            config =
                newlines_after_classes:
                    level: 'error'
                    value: 4
                indentation:
                    level: 'ignore'
                    value: 4
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 1)
            error = errors[0]
            msg = 'Wrong count of newlines between a class and other code'
            assert.equal(error.message, msg)
            assert.equal(error.rule, 'newlines_after_classes')
            assert.equal(error.lineNumber, 11)
            assert.equal(error.context, "Expected 4 got 3")
        
        "has too many newlines after class" : (source) ->
            config =
                newlines_after_classes:
                    level: 'error'
                    value: 2
                indentation:
                    level: 'ignore'
                    value: 4
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 1)
            error = errors[0]
            msg = 'Wrong count of newlines between a class and other code'
            assert.equal(error.message, msg)
            assert.equal(error.rule, 'newlines_after_classes')
            assert.equal(error.lineNumber, 11)
            assert.equal(error.context, "Expected 2 got 3")
        
        "works OK" : (source) ->
            config =
                newlines_after_classes:
                    level: 'error'
                    value: 3
                indentation:
                    level: 'ignore'
                    value: 4
            errors = coffeelint.lint(source, config)
            assert.equal(errors.length, 0)
      ###
    
}).export(module)
