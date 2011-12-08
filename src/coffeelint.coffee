###
CoffeeLint

Copyright (c) 2011 Matthew Perpick.
CoffeeLint is freely distributable under the MIT license.
###


CoffeeScript = require 'coffee-script'


coffeelint = if exports?
    exports
else
    this.coffeelint = {}


coffeelint.VERSION = "0.0.3"


# A set of sane default lint rules.
DEFAULT_CONFIG =
    tabs : false        # Allow tabs for indentation.
    trailing : false    # Allow trailing whitespace.
    lineLength : 80     # The maximum length of each line.
    indent: 2           # Indentation is two characters.


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
# checks on the source
checkTokens = (source, config) ->
    tokens = CoffeeScript.tokens(source)
    errors = []
    for token in tokens when not token.generated?
        [type, value, line] = token
        check = lexChecks[type]
        error = if check then check(config, token) else null
        if error
            error.line = line
            errors.push(error)
    return errors

# Lint the given source text with given user configuration and return a list
# of any errors encountered.
coffeelint.lint = (source, userConfig={}) ->
    config = defaults(userConfig)
    config.indent = 1 if config.tabs
    checkLines(source, config).concat(checkTokens(source, config))


#
# A set of checks on lex tokens provided by the CoffeeScript lexer.
#
lexChecks =

    INDENT : (config, token) ->
        [type, value, line] = token
        if config.indent and value != config.indent
            info = " Expected: #{config.indent} Got: #{value}"
            error = {reason: MESSAGES.INDENTATION_ERROR + info}
        else
            null

#
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


#
# Messages shown to users.
#

MESSAGES =
    NO_TABS : 'Tabs are forbidden'
    TRAILING_WHITESPACE : 'Contains trailing whitespace'
    LINE_LENGTH_EXCEEDED : 'Maximum line length exceeded'
    INDENTATION_ERROR: 'Indentation error'
