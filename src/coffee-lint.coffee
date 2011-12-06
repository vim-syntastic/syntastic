###
CoffeeLint

Copyright (c) 2011 Matthew Perpick.
CoffeeLint is freely distributable under the MIT license.
###


fs = require('fs')
path = require('path')


# Export the CoffeeLint module.
coffeelint = exports

# The current CoffeeLint version.
coffeelint.VERSION = do ->
    package = path.join(__dirname, '..', 'package.json')
    JSON.parse(fs.readFileSync(package)).version



# A set of sane default lint rules.
DEFAULT_CONFIG =
    tabs : false

# Messages shown to users.
MESSAGES =
    NO_TABS : 'Tabs are forbidden'


#
# Utility functions.
#

extend = (destination, sources...) ->
    for source in sources
        (destination[k] = v for k, v of source)
    return destination


defaults = (userConfig) ->
    extend({}, DEFAULT_CONFIG, userConfig)


#
# Linting code.
#


# Lint the given source text with given user configuration and return a list
# of any errors encountered.
coffeelint.lint = (source, userConfig) ->
    config = defaults(userConfig)
    errors = []
    lines = source.split('\n')
    for line, lineNumber in lines
        for rule, check of lineChecks
            error = check(line, config)
            if error
                error.line = lineNumber
                error.evidence = line
                errors.push(error)
    return errors


# A set of checks that should be performed on every line.
lineChecks =

    # Return an error report if the given line has tabs.
    checkTabs : (line, config) ->
        error = null
        if line.indexOf("\t") == 0 and not config.tabs
            error =
                character: 0
                reason: MESSAGES.NO_TABS
        return error

