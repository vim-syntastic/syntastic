###
CoffeeLint

Copyright (c) 2011 Matthew Perpick.
CoffeeLint is freely distributable under the MIT license.
###


# Coffeelint's namespace.
coffeelint = {}

if exports?
    # If we're running in node, export our module and
    # load dependencies.
    coffeelint = exports
    CoffeeScript = require 'coffee-script'
else
    # If we're in the browser, export out module to
    # global scope. Assume CoffeeScript is already
    # loaded.
    this.coffeelint = coffeelint
    CoffeeScript = this.CoffeeScript


# The current version of Coffeelint.
coffeelint.VERSION = "0.0.4"


# A set of sane default lint rules.
DEFAULT_CONFIG =
    tabs : false              # Allow tabs for indentation.
    trailing : false          # Allow trailing whitespace.
    lineLength : 80           # The maximum length of each line.
    indent: 2                 # Indentation is two characters.
    camelCaseClasses: true    # Enforce camel case class names.
    trailingSemicolons: false # Allow trailing semicolons.


# Regexes that are used repeatedly.
regexes =
    trailingWhitespace : /\s+$/
    indentation: /\S/
    camelCase: /^[A-Z][a-zA-Z\d]*$/
    trailingSemicolon: /;$/


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

    constructor : (source, config, tokensByLine) ->
        @source = source
        @config = config
        @line = null
        @lineNumber = 0
        @tokensByLine = tokensByLine

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
                @checkLineLength() or
                @checkTrailingSemicolon()
        error

    checkTabs : () ->
        return null if @config.tabs
        indentation = @line.split(regexes.indentation)[0]
        # Only check lines that have compiled tokens. This helps
        # us ignore tabs in the middle of multi line strings, heredocs, etc.
        # since they are all reduced to a single token whose line number
        # is the start of the expression.
        if @lineHasToken() and  ~indentation.indexOf('\t')
            character: 0
            reason: MESSAGES.NO_TABS
        else
            null

    # Return true if the given line actually has tokens.
    lineHasToken : () ->
        return @tokensByLine[@lineNumber]?

    # Return tokens for the given line number.
    getLineTokens : () ->
        @tokensByLine[@lineNumber] || []

    checkTrailingWhitespace : () ->
        if not @config.trailing and regexes.trailingWhitespace.test(@line)
            character: @line.length
            reason: MESSAGES.TRAILING_WHITESPACE

    checkLineLength : () ->
        lineLength = @config.lineLength
        if lineLength and lineLength < @line.length
            character: 0
            reason: MESSAGES.LINE_LENGTH_EXCEEDED

    checkTrailingSemicolon : () ->
        return null if @config.trailingSemiColons
        hasSemicolon = regexes.trailingSemicolon.test(@line)
        [first..., last] = @getLineTokens()
        hasNewLine = last and last.newLine?
        # Don't throw errors when the contents of  multiline strings,
        # regexes and the like end in ";"
        if hasSemicolon and not hasNewLine and @lineHasToken()
            reason: "Unnecessary semicolon"
        else
            return null

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
            info = " Expected: #{@config.indent} Got: #{numIndents}"
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

    # Do lexical linting.
    lexicalLinter = new LexicalLinter(source, config)
    lexErrors = lexicalLinter.lint()

    # Do line linting.
    tokensByLine = lexicalLinter.tokensByLine
    lineLinter = new LineLinter(source, config, tokensByLine)
    lineErrors = lineLinter.lint()

    # Sort by line number and return.
    errors = lexErrors.concat(lineErrors)
    errors.sort((a, b) -> a.line - b.line)
    errors

#
# Messages shown to users.
#

MESSAGES =
    NO_TABS : 'Tabs are forbidden'
    TRAILING_WHITESPACE : 'Contains trailing whitespace'
    LINE_LENGTH_EXCEEDED : 'Maximum line length exceeded'
    INDENTATION_ERROR: 'Indentation error.'
    INVALID_CLASS_NAME: 'Invalid class name'
