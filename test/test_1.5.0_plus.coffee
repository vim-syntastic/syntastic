path = require 'path'
vows = require 'vows'
assert = require 'assert'
CoffeeScript = require 'coffee-script'
CoffeeScript.old_tokens = CoffeeScript.tokens
CoffeeScript.tokens = (text) ->
    tokens = CoffeeScript.old_tokens(text)
    for token in tokens
        if typeof token[2] == "number"
            token[2] = {first_line: token[2]}
        token
coffeelint = require path.join('..', 'lib', 'coffeelint')

batches = []
vow = vows.describe("CoffeeScript 1.5.0+")

require('fs').readdirSync('./test').forEach (file) ->
    if file.match(/\.coffee$/) and not file.match(/test_1\.5\.0_plus.coffee$/)
        test = require "./#{file}"
        for own test_name, suite of test
            batches.push({})
            for batch in suite.batches
                new_batch = {}
                new_batch[test_name] = batch.tests
                vow = vow.addBatch(new_batch)

vow.addBatch({

    "Cleanup" : () ->

        CoffeeScript.tokens = CoffeeScript.old_tokens
        delete CoffeeScript.old_tokens

}).export(module)
