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


#
# A class that performs regex checks on each line of the source.
#
class LineLinter

    constructor : (source, config) ->
        @source = source
        @config = config
        @line = null
        @lineNumber = 0

    lint : () ->
        errors = []
        for line, lineNumber in @source.split('\n')
            @lineNumber = lineNumber
            @line = line
            error = @lintLine()
            if error
                error.line = @lineNumber
                error.evidence = @line
                errors.push(error) if error
        errors

    lintLine : () ->
        error = @checkTabs() or
                @checkTrailingWhitespace() or
                @checkLineLength()
        error

    checkTabs : () ->
        return null if @config.tabs
        indentation = @line.split(regexes.indentation)[0]
        if ~indentation.indexOf('\t')
            character: 0
            reason: MESSAGES.NO_TABS
        else
            null

    checkTrailingWhitespace : () ->
        if not @config.trailing and regexes.trailingWhitespace.test(@line)
            character: @line.length
            reason: MESSAGES.TRAILING_WHITESPACE

    checkLineLength : () ->
        lineLength = @config.lineLength
        if lineLength and lineLength < @line.length
            character: 0
            reason: MESSAGES.LINE_LENGTH_EXCEEDED

#
# A class that performs checks on the output of CoffeeScript's
# lexer.
#
class LexicalLinter

    constructor : (source, config) ->
        @source = source
        @tokens = CoffeeScript.tokens(source)
        @config = config
        @i = 0              # The index of the current token we're linting.
        @tokensByLine = {}  # A map of tokens by line.

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

        @tokensByLine[line] ?= []
        @tokensByLine[line].push(token)

        # Now lint it.
        switch type
            when "INDENT" then @lintIndentation(token)
            when "CLASS"  then @lintClass(token)
            else null

    # Return an error if the given indentation token is not correct.
    lintIndentation : (token) ->
        [type, numIndents, line] = token

        # HACK: CoffeeScript's lexer insert indentation in string
        # interpolations that start with spaces e.g. "#{ 123 }"
        # so ignore such cases. Are there other times an indentation
        # could possibly follow a '+'?
        previousToken = @peek(-2)
        inInterp = previousToken and previousToken[0] == '+'

        # Now check the indentation.
        if @config.indent and not inInterp and numIndents != @config.indent
            info = "Expected: #{@config.indent} Got: #{numIndents}"
            error = {reason: MESSAGES.INDENTATION_ERROR + info, line: line}
        else
            null

    lintClass : (token) ->
        # TODO: you can do some crazy shit in CoffeeScript, like
        # class func().ClassName. Don't allow that.

        [type, value, line] = @peek()
        className = null

        # It's common to assign a class to a global namespace, e.g.
        # exports.MyClassName, so loop through the next tokens until
        # we find the real identifier.
        #
        offset = 1
        until className
            if @peek(offset + 1)?[0] == '.'
                offset += 2
            else
                className = @peek(offset)[1]

        # Now check for the error.
        if @config.camelCaseClasses and not regexes.camelCase.test(className)
            {
                reason: MESSAGES.INVALID_CLASS_NAME
                line: line
                evidence: className
            }
        else
            null

    peek : (n=1) ->
        @tokens[@i + n] || null

# Lint the given source text with given user configuration and return a list
# of any errors encountered.
coffeelint.lint = (source, userConfig={}) ->
    config = defaults(userConfig)
    config.indent = 1 if config.tabs

    lexicalLinter = new LexicalLinter(source, config)
    lexErrors = lexicalLinter.lint()

    lineLinter = new LineLinter(source, config)
    lineErrors = lineLinter.lint()

    return lexErrors.concat(lineErrors)

#
# Messages shown to users.
#

MESSAGES =
    NO_TABS : 'Tabs are forbidden'
    TRAILING_WHITESPACE : 'Contains trailing whitespace'
    LINE_LENGTH_EXCEEDED : 'Maximum line length exceeded'
    INDENTATION_ERROR: 'Indentation error'
    INVALID_CLASS_NAME: 'Invalid class name'
