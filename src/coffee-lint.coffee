###
CoffeeLint

Copyright (c) 2011 Matthew Perpick
###



fs = require('fs')
path = require('path')


# Export the CoffeeLint module.
coffeelint = exports

# The current CoffeeLint version.
coffeelint.VERSION = do ->
    package = path.join(__dirname, '..', 'package.json')
    JSON.parse(fs.readFileSync(package)).version
