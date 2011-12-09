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
    tabs : false            # Allow tabs for indentation.
    trailing : false        # Allow trailing whitespace.
    lineLength : 80         # The maximum length of each line.
    indent: 2               # Indentation is two characters.
    camelCaseClasses: true  # Enforce camel case class names.


# Regexes that are used repeatedly.
regexes =
    trailingWhitespace : /\s+$/
    indentation: /\S/
    camelCase: /^[A-Z][a-zA-Z\d]*$/


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


#
# A class that performs checks on the output of CoffeeScript's
# lexer.
#
class LexicalLinter

    constructor : (source, config) ->
        @tokens = CoffeeScript.tokens(source)
        @config = config
        @i = 0

    # Return a list of errors encountered in the given source.
    lint : () ->
        errors = []
        for token, i in @tokens when not token.generated?
            @i = i
            error = @lintToken(token)
            errors.push(error) if error
        errors

    # Return an error if the given token fails a lint check, false
    # otherwise.
    lintToken : (token) ->
        [type, value, line] = token
        switch type
            when "INDENT" then @lintIndentation(token)
            when "CLASS"  then @lintClass(token)
            else null

    # Return an error if the given indentation token is not correct.
    lintIndentation : (token) ->
        [type, numIndents, line] = token
        previousToken = @peekBack(2)

        # HACK: CoffeeScript's lexer insert indentation in string
        # interpolations that start with spaces e.g. "#{ 123 }"
        # so ignore such cases. Are there other times an indentation
        # could possibly follow a '+'?
        inInterp = previousToken and previousToken[0] == '+'
        if @config.indent and not inInterp and numIndents != @config.indent
            info = "Expected: #{@config.indent} Got: #{numIndents}"
            error = {reason: MESSAGES.INDENTATION_ERROR + info, line: line}
        else
            null

    lintClass : (token) ->
        [type, className, line] = @peek()
        if @config.camelCaseClasses and not regexes.camelCase.test(className)
            {
                reason: MESSAGES.INVALID_CLASS_NAME
                line: line
                evidence: className
            }
        else
            null

    # Return the next token in the stream.
    peek : (n=1) ->
        @tokens[@i + n] || null

    # Return the previous token in the stream.
    peekBack : (n=1) ->
        @tokens[@i - n] || null

# Lint the given source text with given user configuration and return a list
# of any errors encountered.
coffeelint.lint = (source, userConfig={}) ->
    config = defaults(userConfig)
    config.indent = 1 if config.tabs

    lexicalLinter = new LexicalLinter(source, config)
    checkLines(source, config).concat(lexicalLinter.lint())

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
    INVALID_CLASS_NAME: 'Invalid class name'
