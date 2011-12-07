###
CoffeeLint

Copyright (c) 2011 Matthew Perpick.
CoffeeLint is freely distributable under the MIT license.
###


coffeelint = if exports?
  exports
else
  this.coffeelint = {}


coffeelint.VERSION = "0.0.2"


# A set of sane default lint rules.
DEFAULT_CONFIG =
    tabs : false        # Allow tabs for indentation.
    trailing : false    # Allow trailing whitespace.
    lineLength : 80     # The maximum length of each line.
# Regexes that are used repeatedly.
regexes =
    trailingWhitespace : /\s+$/
    indentation: /\S/


# Patch the source properties onto the destination.
extend = (destination, sources...) ->
    for source in sources
        (destination[k] = v for k, v of source)
    return destination

# Return a map of config options with any unspecified options
# patched with defaults.
defaults = (userConfig) ->
    extend({}, DEFAULT_CONFIG, userConfig)


# Return a list of errors found by performing "line"
# checks on the source.
checkLines = (source, config) ->
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

# Return a list of errors found by performing "lex"
# checks on the source.
checkTokens = (source, config) ->
    return []


# Lint the given source text with given user configuration and return a list
# of any errors encountered.
coffeelint.lint = (source, userConfig={}) ->
    config = defaults(userConfig)
    checkLines(source, config).concat(checkTokens(source, config))

#
# A set of checks that should be performed on every line.
#
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

#
# Messages shown to users.
#

MESSAGES =
    NO_TABS : 'Tabs are forbidden'
    TRAILING_WHITESPACE : 'Contains trailing whitespace'
    LINE_LENGTH_EXCEEDED : 'Maximum line length exceeded'
