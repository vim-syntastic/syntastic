path = require 'path'
vows = require 'vows'
assert = require 'assert'
coffeelint = require path.join('..', 'lib', 'coffeelint')

vows.describe('spacing').addBatch({

    'No spaces around binary operators' :

        topic : ->
            '''
            x=1
            1+1
            1-1
            1/1
            1*1
            1==1
            1>=1
            1>1
            1<1
            1<=1
            1%1
            (a='b') -> a
            a|b
            a&b
            a*=-5
            a*=-b
            a*=5
            a*=a
            -a+=-2
            -a+=-a
            -a+=2
            -a+=a
            a*-b
            '''

        'are permitted by default' : (source) ->
            errors = coffeelint.lint(source)
            assert.isEmpty(errors)

        'can be forbidden' : (source) ->
            config = {space_operators : {level:'error'}}
            errors = coffeelint.lint(source, config)
            assert.lengthOf(errors, source.split("\n").length)
            error = errors[0]
            assert.equal(error.rule, 'space_operators')
            assert.equal(error.lineNumber, 1)
            assert.equal(error.message, "Operators must be spaced properly")

    'Correctly spaced operators' :

        topic : ->
            '''
            x = 1
            1 + 1
            1 - 1
            1 / 1
            1 * 1
            1 == 1
            1 >= 1
            1 > 1
            1 < 1
            1 <= 1
            (a = 'b') -> a
            +1
            -1
            y = -2
            x = -1
            y = x++
            x = y++
            1 + (-1)
            -1 + 1
            x(-1)
            x(-1, 1, -1)
            x[..-1]
            x[-1..]
            x[-1...-1]
            1 < -1
            a if -1
            a unless -1
            a if -1 and 1
            a if -1 or 1
            1 and -1
            1 or -1
            "#{a}#{b}"
            [+1, -1]
            [-1, +1]
            {a: -1}
            /// #{a} ///
            if -1 then -1 else -1
            a | b
            a & b
            a *= 5
            a *= -5
            a *= b
            a *= -b
            -a *= 5
            -a *= -5
            -a *= b
            -a *= -b
            a * -b
            return -1
            '''

        'are permitted' : (source) ->
            config = {space_operators : {level:'error'}}
            errors = coffeelint.lint(source, config)
            assert.isEmpty(errors)

    'Spaces around unary operators' :

        topic : ->
            '''
            + 1
            - - 1
            '''

        'are permitted by default' : (source) ->
            errors = coffeelint.lint(source)
            assert.isEmpty(errors)

        'can be forbidden' : (source) ->
            config = {space_operators : {level:'error'}}
            errors = coffeelint.lint(source, config)
            assert.lengthOf(errors, 2)
            error = errors[0]

}).export(module)

