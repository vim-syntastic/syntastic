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
coffeelint.VERSION = "0.2.0"


# CoffeeLint error levels.
ERROR   = 'error'
WARN    = 'warn'
IGNORE  = 'ignore'


# CoffeeLint's default rule configuration.
RULES =

    no_tabs :
        level : ERROR
        message : 'Line contains tab indentation'

    no_trailing_whitespace :
        level : ERROR
        message : 'Line ends with trailing whitespace'

    max_line_length :
        value: 80
        level : ERROR
        message : 'Line exceeds maximum allowed length'

    camel_case_classes :
        level : ERROR
        message : 'Class names should be camel cased'

    indentation :
        value : 2
        level : ERROR
        message : 'Line contains inconsistent indentation'

    no_implicit_braces :
        level : IGNORE
        message : 'Implicit braces are forbidden'

    no_trailing_semicolons:
        level : ERROR
        message : 'Line contains a trailing semicolon'

    no_plusplus:
        level : IGNORE
        message : 'The increment and decrement operators are forbidden'

    no_throwing_strings:
        level : ERROR
        message : 'Throwing strings is forbidden'

    cyclomatic_complexity:
        value : 10
        level : IGNORE
        message : 'The cyclomatic complexity is too damn high'


# Some repeatedly used regular expressions.
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

# Patch any missing attributes from defaults to source.
defaults = (source, defaults) ->
    extend({}, defaults, source)


# Create an error object for the given rule with the given
# attributes.
createError = (rule, attrs={}) ->
    level = attrs.level
    if level not in [IGNORE, WARN, ERROR]
        throw new Error("unknown level #{level}")

    if level in [ERROR, WARN]
        attrs.rule = rule
        return defaults(attrs, RULES[rule])
    else
        null

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
            errors.push(error) if error
        errors

    # Return an error if the line contained failed a rule, null otherwise.
    lintLine : () ->
        return @checkTabs() or
               @checkTrailingWhitespace() or
               @checkLineLength() or
               @checkTrailingSemicolon()

    checkTabs : () ->
        # Only check lines that have compiled tokens. This helps
        # us ignore tabs in the middle of multi line strings, heredocs, etc.
        # since they are all reduced to a single token whose line number
        # is the start of the expression.
        indent = @line.split(regexes.indentation)[0]
        if @lineHasToken() and ~indent.indexOf('\t')
            @createLineError('no_tabs')
        else
            null

    checkTrailingWhitespace : () ->
        if regexes.trailingWhitespace.test(@line)
            @createLineError('no_trailing_whitespace')
        else
            null

    checkLineLength : () ->
        rule = 'max_line_length'
        max = @config[rule]?.value
        if max and max < @line.length
            @createLineError(rule)
        else
            null

    checkTrailingSemicolon : () ->
        hasSemicolon = regexes.trailingSemicolon.test(@line)
        [first..., last] = @getLineTokens()
        hasNewLine = last and last.newLine?
        # Don't throw errors when the contents of  multiline strings,
        # regexes and the like end in ";"
        if hasSemicolon and not hasNewLine and @lineHasToken()
            @createLineError('no_trailing_semicolons')
        else
            return null

    createLineError : (rule) ->
        attrs =
            lineNumber: @lineNumber + 1 # Lines are indexed by zero.
            level: @config[rule]?.level
        createError(rule, attrs)

    # Return true if the given line actually has tokens.
    lineHasToken : () ->
        return @tokensByLine[@lineNumber]?

    # Return tokens for the given line number.
    getLineTokens : () ->
        @tokensByLine[@lineNumber] || []

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
        @arrayTokens = []   # A stack tracking the array token pairs.

    # Return a list of errors encountered in the given source.
    lint : () ->
        errors = []
        for token, i in @tokens
            @i = i
            error = @lintToken(token)
            errors.push(error) if error
        errors

    # Return an error if the given token fails a lint check, false
    # otherwise.
    lintToken : (token) ->
        [type, value, lineNumber] = token

        @tokensByLine[lineNumber] ?= []
        @tokensByLine[lineNumber].push(token)
        @lineNumber = lineNumber

        # Now lint it.
        switch type
            when "INDENT"    then @lintIndentation(token)
            when "CLASS"     then @lintClass(token)
            when "{"         then @lintBrace(token)
            when "++", "--"  then @lintIncrement(token)
            when "THROW"     then @lintThrow(token)
            when "[", "]"    then @lintArray(token)
            else null

    # Lint the given array token.
    lintArray : (token) ->
        # Track the array token pairs
        if token[0] == '['
            @arrayTokens.push(token)
        else if token[0] == ']'
            @arrayTokens.pop()
        # Return null, since we're not really linting
        # anything here.
        null

    lintBrace : (token) ->
        if token.generated then @createLexError('no_implicit_braces') else null

    lintThrow : (token) ->
        [n1, n2] = [@peek(), @peek(2)]
        # Catch literals and string interpolations, which are wrapped in
        # parens.
        nextIsString = n1[0] == 'STRING' or (n1[0] == '(' and n2[0] == 'STRING')
        @createLexError('no_throwing_strings') if nextIsString

    lintIncrement : (token) ->
        attrs = {context : "found '#{token[0]}'"}
        @createLexError('no_plusplus', attrs)

    # Return an error if the given indentation token is not correct.
    lintIndentation : (token) ->
        [type, numIndents, lineNumber] = token

        return null if token.generated?

        # HACK: CoffeeScript's lexer insert indentation in string
        # interpolations that start with spaces e.g. "#{ 123 }"
        # so ignore such cases. Are there other times an indentation
        # could possibly follow a '+'?
        previous = @peek(-2)
        isInterpIndent = previous and previous[0] == '+'

        # Ignore the indentation inside of an array, so that
        # we can allow things like:
        #   x = ["foo",
        #             "bar"]
        previous = @peek(-1)
        isArrayIndent = @inArray() and previous?.newLine

        # Ignore indents used to for formatting on multi-line expressions, so
        # we can allow things like:
        #   a = b =
        #     c = d
        # and:
        #   test(1234,
        #             456)
        previousSymbol = @peek(-1)?[0]
        isMultiline = previousSymbol in ['=', ',']

        # Summarize the indentation conditions we'd like to ignore
        ignoreIndent = isInterpIndent or isArrayIndent or isMultiline

        # Now check the indentation.
        expected = @config['indentation'].value
        if not ignoreIndent and numIndents != expected
            context = "Expected #{expected} " +
                      "got #{numIndents}"
            @createLexError('indentation', {context})
        else
            null

    lintClass : (token) ->
        # TODO: you can do some crazy shit in CoffeeScript, like
        # class func().ClassName. Don't allow that.

        # Don't try to lint the names of anonymous classes.
        return null if token.newLine? or @peek()[0] is 'EXTENDS'

        # It's common to assign a class to a global namespace, e.g.
        # exports.MyClassName, so loop through the next tokens until
        # we find the real identifier.
        className = null
        offset = 1
        until className
            if @peek(offset + 1)?[0] == '.'
                offset += 2
            else if @peek(offset)?[0] == '@'
                offset += 1
            else
                className = @peek(offset)[1]

        # Now check for the error.
        if not regexes.camelCase.test(className)
            attrs = {context: "class name: #{className}"}
            @createLexError('camel_case_classes', attrs)
        else
            null

    createLexError : (rule, attrs={}) ->
        attrs.lineNumber = @lineNumber + 1
        attrs.level = @config[rule].level
        createError(rule, attrs)

    # Return the token n places away from the current token.
    peek : (n=1) ->
        @tokens[@i + n] || null

    # Return true if the current token is inside of an array.
    inArray : () ->
        return @arrayTokens.length > 0


# A class that performs static analysis of the abstract
# syntax tree.
class ASTLinter

    constructor : (source, config) ->
        @source = source
        @config = config
        @node = CoffeeScript.nodes(source)
        @errors = []
        @stack = []
        @blocks = 0

    lint : () ->
        @lintNode(@node)
        @errors

    # Lint the AST node and return it's cyclomatic complexity.
    lintNode : (node) ->

        # Get the complexity of the current node.
        name = node.constructor.name
        complexity = if name in ['If', 'While', 'For', 'Try']
            1
        else if name == 'Op' and node.operator in ['&&', '||']
            1
        else if name == 'Switch'
            node.cases.length
        else
            0

        # Add the complexity of all child's nodes to this one.
        node.eachChild (childNode) =>
            return false unless childNode
            complexity += @lintNode(childNode)
            return true

        # If the current node is a function, and it's over our limit, add an
        # error to the list.
        rule = @config.cyclomatic_complexity
        if name == 'Code' and complexity >= rule.value
            attrs = {
                context: complexity + 1
                level: rule.level
                line: 0
            }
            error = createError 'cyclomatic_complexity', attrs
            @errors.push error if error

        # Return the complexity for the benefit of parent nodes.
        return complexity

# Merge default and user configuration.
mergeDefaultConfig = (userConfig) ->
    config = {}
    for rule, ruleConfig of RULES
        config[rule] = defaults(userConfig[rule], ruleConfig)
    return config


# Check the source against the given configuration and return an array
# of any errors found. An error is an object with the following
# properties:
#
#   {
#       rule :      'Name of the violated rule',
#       lineNumber: 'Number of the line that caused the violation',
#       level:      'The error level of the violated rule',
#       message:    'Information about the violated rule',
#       context:    'Optional details about why the rule was violated'
#   }
#
coffeelint.lint = (source, userConfig={}) ->
    config = mergeDefaultConfig(userConfig)

    # Do lexical linting.
    lexicalLinter = new LexicalLinter(source, config)
    lexErrors = lexicalLinter.lint()

    # Do line linting.
    tokensByLine = lexicalLinter.tokensByLine
    lineLinter = new LineLinter(source, config, tokensByLine)
    lineErrors = lineLinter.lint()

    # Do AST linting.
    astErrors = new ASTLinter(source, config).lint()

    # Sort by line number and return.
    errors = lexErrors.concat(lineErrors, astErrors)
    errors.sort((a, b) -> a.lineNumber - b.lineNumber)
    errors

