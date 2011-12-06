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


#
# A set of sane default lint rules.
#

DEFAULT_CONFIG =
    tabs : false        # Allow tabs for indentation.
    trailing : false    # Allow trailing whitespace.
    lineLength : 80     # The maximum length of each line.

#
# Error messages shown to users
#

MESSAGES =
    NO_TABS : 'Tabs are forbidden'
    TRAILING_WHITESPACE : 'Contains trailing whitespace'
    LINE_LENGTH_EXCEEDED : 'Maximum line length exceeded'


# Regular expressions
regexes =
    trailingWhitespace : /\s+$/
    indentation: /\S/


# Utility functions.
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
coffeelint.lint = (source, userConfig={}) ->
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

    checkTabs : (line, config) ->
        return null if config.tabs
        indentation = line.split(regexes.indentation)[0]
        if ~indentation.indexOf('\t')
            character: 0
            reason: MESSAGES.NO_TABS

    checkTrailingWhitespace : (line, config) ->
        if not config.trailing and regexes.trailingWhitespace.test(line)
            character: line.length
            reason: MESSAGES.TRAILING_WHITESPACE
        else
            null

    checkLineLength : (line, config) ->
        lineLength = config.lineLength
        if lineLength and lineLength < line.length
            character: 0
            reason: MESSAGES.LINE_LENGTH_EXCEEDED
        else
            null
