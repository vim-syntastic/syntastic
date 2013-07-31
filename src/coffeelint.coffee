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
coffeelint.VERSION = "0.5.7"


# CoffeeLint error levels.
ERROR   = 'error'
WARN    = 'warn'
IGNORE  = 'ignore'


# CoffeeLint's default rule configuration.
coffeelint.RULES = RULES =

    no_tabs :
        level : ERROR
        message : 'Line contains tab indentation'
        description: """
            This rule forbids tabs in indentation. Enough said. It is enabled by
            default.
            """

    no_trailing_whitespace :
        level : ERROR
        message : 'Line ends with trailing whitespace'
        allowed_in_comments : false
        description: """
            This rule forbids trailing whitespace in your code, since it is
            needless cruft. It is enabled by default.
            """

    max_line_length :
        value: 80
        level : ERROR
        message : 'Line exceeds maximum allowed length'
        description: """
            This rule imposes a maximum line length on your code. <a
            href="http://www.python.org/dev/peps/pep-0008/">Python's style
            guide</a> does a good job explaining why you might want to limit the
            length of your lines, though this is a matter of taste.

            Lines can be no longer than eighty characters by default.
            """

    camel_case_classes :
        level : ERROR
        message : 'Class names should be camel cased'
        description: """
            This rule mandates that all class names are camel cased. Camel
            casing class names is a generally accepted way of distinguishing
            constructor functions - which require the 'new' prefix to behave
            properly - from plain old functions.
            <pre>
            <code># Good!
            class BoaConstrictor

            # Bad!
            class boaConstrictor
            </code>
            </pre>
            This rule is enabled by default.
            """
    indentation :
        value : 2
        level : ERROR
        message : 'Line contains inconsistent indentation'
        description: """
            This rule imposes a standard number of spaces to be used for
            indentation. Since whitespace is significant in CoffeeScript, it's
            critical that a project chooses a standard indentation format and
            stays consistent. Other roads lead to darkness. <pre> <code>#
            Enabling this option will prevent this ugly
            # but otherwise valid CoffeeScript.
            twoSpaces = () ->
              fourSpaces = () ->
                  eightSpaces = () ->
                        'this is valid CoffeeScript'

            </code>
            </pre>
            Two space indentation is enabled by default.
            """

    no_implicit_braces :
        level : IGNORE
        message : 'Implicit braces are forbidden'
        description: """
            This rule prohibits implicit braces when declaring object literals.
            Implicit braces can make code more difficult to understand,
            especially when used in combination with optional parenthesis.
            <pre>
            <code># Do you find this code ambiguous? Is it a
            # function call with three arguments or four?
            myFunction a, b, 1:2, 3:4

            # While the same code written in a more
            # explicit manner has no ambiguity.
            myFunction(a, b, {1:2, 3:4})
            </code>
            </pre>
            Implicit braces are permitted by default, since their use is
            idiomatic CoffeeScript.
            """

    no_trailing_semicolons:
        level : ERROR
        message : 'Line contains a trailing semicolon'
        description: """
            This rule prohibits trailing semicolons, since they are needless
            cruft in CoffeeScript.
            <pre>
            <code># This semicolon is meaningful.
            x = '1234'; console.log(x)

            # This semicolon is redundant.
            alert('end of line');
            </code>
            </pre>
            Trailing semicolons are forbidden by default.
            """

    no_plusplus:
        level : IGNORE
        message : 'The increment and decrement operators are forbidden'
        description: """
            This rule forbids the increment and decrement arithmetic operators.
            Some people believe the <tt>++</tt> and <tt>--</tt> to be cryptic
            and the cause of bugs due to misunderstandings of their precedence
            rules.
            This rule is disabled by default.
            """

    no_throwing_strings:
        level : ERROR
        message : 'Throwing strings is forbidden'
        description: """
            This rule forbids throwing string literals or interpolations. While
            JavaScript (and CoffeeScript by extension) allow any expression to
            be thrown, it is best to only throw <a
            href="https://developer.mozilla.org
            /en/JavaScript/Reference/Global_Objects/Error"> Error</a> objects,
            because they contain valuable debugging information like the stack
            trace. Because of JavaScript's dynamic nature, CoffeeLint cannot
            ensure you are always throwing instances of <tt>Error</tt>. It will
            only catch the simple but real case of throwing literal strings.
            <pre>
            <code># CoffeeLint will catch this:
            throw "i made a boo boo"

            # ... but not this:
            throw getSomeString()
            </code>
            </pre>
            This rule is enabled by default.
            """

    cyclomatic_complexity:
        value : 10
        level : IGNORE
        message : 'The cyclomatic complexity is too damn high'

    no_backticks:
        level : ERROR
        message : 'Backticks are forbidden'
        description: """
            Backticks allow snippets of JavaScript to be embedded in
            CoffeeScript. While some folks consider backticks useful in a few
            niche circumstances, they should be avoided because so none of
            JavaScript's "bad parts", like <tt>with</tt> and <tt>eval</tt>,
            sneak into CoffeeScript.
            This rule is enabled by default.
            """

    line_endings:
        level : IGNORE
        value : 'unix' # or 'windows'
        message : 'Line contains incorrect line endings'
        description: """
            This rule ensures your project uses only <tt>windows</tt> or
            <tt>unix</tt> line endings. This rule is disabled by default.
            """
    no_implicit_parens :
        level : IGNORE
        message : 'Implicit parens are forbidden'
        description: """
            This rule prohibits implicit parens on function calls.
            <pre>
            <code># Some folks don't like this style of coding.
            myFunction a, b, c

            # And would rather it always be written like this:
            myFunction(a, b, c)
            </code>
            </pre>
            Implicit parens are permitted by default, since their use is
            idiomatic CoffeeScript.
            """

    empty_constructor_needs_parens :
        level : IGNORE
        message : 'Invoking a constructor without parens and without arguments'

    non_empty_constructor_needs_parens :
        level : IGNORE
        message : 'Invoking a constructor without parens and with arguments'

    no_empty_param_list :
        level : IGNORE
        message : 'Empty parameter list is forbidden'
        description: """
            This rule prohibits empty parameter lists in function definitions.
            <pre>
            <code># The empty parameter list in here is unnecessary:
            myFunction = () -&gt;

            # We might favor this instead:
            myFunction = -&gt;
            </code>
            </pre>
            Empty parameter lists are permitted by default.
            """


    space_operators :
        level : IGNORE
        message : 'Operators must be spaced properly'

    # I don't know of any legitimate reason to define duplicate keys in an
    # object. It seems to always be a mistake, it's also a syntax error in
    # strict mode.
    # See http://jslinterrors.com/duplicate-key-a/
    duplicate_key :
        level : ERROR
        message : 'Duplicate key defined in object or class'

    newlines_after_classes :
        value : 3
        level : IGNORE
        message : 'Wrong count of newlines between a class and other code'

    no_stand_alone_at :
        level : IGNORE
        message : '@ must not be used stand alone'
        description: """
            This rule checks that no stand alone @ are in use, they are
            discouraged. Further information in CoffeScript issue <a
            href="https://github.com/jashkenas/coffee-script/issues/1601">
            #1601</a>
            """

    arrow_spacing :
        level : IGNORE
        message : 'Function arrow (->) must be spaced properly'
        description: """
            <p>This rule checks to see that there is spacing before and after
            the arrow operator that declares a function. This rule is disabled
            by default.</p> <p>Note that if arrow_spacing is enabled, and you
            pass an empty function as a parameter, arrow_spacing will accept
            either a space or no space in-between the arrow operator and the
            parenthesis</p>
            <pre><code># Both of this will not trigger an error,
            # even with arrow_spacing enabled.
            x(-> 3)
            x( -> 3)

            # However, this will trigger an error
            x((a,b)-> 3)
            </code>
            </pre>
             """

    coffeescript_error :
        level : ERROR
        message : '' # The default coffeescript error is fine.


# Some repeatedly used regular expressions.
regexes =
    trailingWhitespace : /[^\s]+[\t ]+\r?$/
    lineHasComment : /^\s*[^\#]*\#/
    indentation: /\S/
    longUrlComment: ///
      ^\s*\# # indentation, up to comment
      \s*
      http[^\s]+$ # Link that takes up the rest of the line without spaces.
    ///
    camelCase: /^[A-Z][a-zA-Z\d]*$/
    trailingSemicolon: /;\r?$/
    configStatement: /coffeelint:\s*(disable|enable)(?:=([\w\s,]*))?/


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
createError = (rule, attrs = {}) ->
    level = attrs.level
    if level not in [IGNORE, WARN, ERROR]
        throw new Error("unknown level #{level}")

    if level in [ERROR, WARN]
        attrs.rule = rule
        return defaults(attrs, RULES[rule])
    else
        null

# Store suppressions in the form of { line #: type }
block_config =
    enable: {}
    disable: {}

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
        @lines = @source.split('\n')
        @lineCount = @lines.length

        # maintains some contextual information
        #   inClass: bool; in class or not
        #   lastUnemptyLineInClass: null or lineNumber, if the last not-empty
        #                     line was in a class it holds its number
        #   classIndents: the number of indents within a class
        @context = {
            class: {
                inClass: false
                lastUnemptyLineInClass: null
                classIndents: null
            }
        }

    lint : () ->
        errors = []
        for line, lineNumber in @lines
            @lineNumber = lineNumber
            @line = line
            @maintainClassContext()
            error = @lintLine()
            errors.push(error) if error
        errors

    # Return an error if the line contained failed a rule, null otherwise.
    lintLine : () ->
        return @checkTabs() or
               @checkTrailingWhitespace() or
               @checkLineLength() or
               @checkTrailingSemicolon() or
               @checkLineEndings() or
               @checkComments() or
               @checkNewlinesAfterClasses()

    checkTabs : () ->
        # Only check lines that have compiled tokens. This helps
        # us ignore tabs in the middle of multi line strings, heredocs, etc.
        # since they are all reduced to a single token whose line number
        # is the start of the expression.
        indentation = @line.split(regexes.indentation)[0]
        if @lineHasToken() and '\t' in indentation
            @createLineError('no_tabs')
        else
            null

    checkTrailingWhitespace : () ->
        if regexes.trailingWhitespace.test(@line)
            # By default only the regex above is needed.
            if !@config['no_trailing_whitespace']?.allowed_in_comments
                return @createLineError('no_trailing_whitespace')

            line = @line
            tokens = @tokensByLine[@lineNumber]

            # If we're in a block comment there won't be any tokens on this
            # line. Some previous line holds the token spanning multiple lines.
            if !tokens
                return null

            # To avoid confusion when a string might contain a "#", every string
            # on this line will be removed. before checking for a comment
            for str in (token[1] for token in tokens when token[0] == 'STRING')
                line = line.replace(str, 'STRING')

            if !regexes.lineHasComment.test(line)
                return @createLineError('no_trailing_whitespace')
            else
                return null
        else
            return null

    checkLineLength : () ->
        rule = 'max_line_length'
        max = @config[rule]?.value
        if max and max < @line.length and not regexes.longUrlComment.test(@line)
            attrs =
                context: "Length is #{@line.length}, max is #{max}"
            @createLineError(rule, attrs)
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

    checkLineEndings : () ->
        rule = 'line_endings'
        ending = @config[rule]?.value

        return null if not ending or @isLastLine() or not @line

        lastChar = @line[@line.length - 1]
        valid = if ending == 'windows'
            lastChar == '\r'
        else if ending == 'unix'
            lastChar != '\r'
        else
            throw new Error("unknown line ending type: #{ending}")
        if not valid
            return @createLineError(rule, {context:"Expected #{ending}"})
        else
            return null

    checkComments : () ->
        # Check for block config statements enable and disable
        result = regexes.configStatement.exec(@line)
        if result?
            cmd = result[1]
            rules = []
            if result[2]?
                for r in result[2].split(',')
                    rules.push r.replace(/^\s+|\s+$/g, "")
            block_config[cmd][@lineNumber] = rules
        return null

    checkNewlinesAfterClasses : () ->
        rule = 'newlines_after_classes'
        ending = @config[rule].value

        return null if not ending or @isLastLine()

        if not @context.class.inClass and
                @context.class.lastUnemptyLineInClass? and
                ((@lineNumber - 1) - @context.class.lastUnemptyLineInClass) isnt
                ending
            got = (@lineNumber - 1) - @context.class.lastUnemptyLineInClass
            return @createLineError( rule, {
                context: "Expected #{ending} got #{got}"
            } )

        null

    createLineError : (rule, attrs = {}) ->
        attrs.lineNumber = @lineNumber + 1 # Lines are indexed by zero.
        attrs.level = @config[rule]?.level
        createError(rule, attrs)

    isLastLine : () ->
        return @lineNumber == @lineCount - 1

    # Return true if the given line actually has tokens.
    # Optional parameter to check for a specific token type and line number.
    lineHasToken : (tokenType = null, lineNumber = null) ->
        lineNumber = lineNumber ? @lineNumber
        unless tokenType?
            return @tokensByLine[lineNumber]?
        else
            tokens = @tokensByLine[lineNumber]
            return null unless tokens?
            for token in tokens
                return true if token[0] == tokenType
            return false

    # Return tokens for the given line number.
    getLineTokens : () ->
        @tokensByLine[@lineNumber] || []

    # maintain the contextual information for class-related stuff
    maintainClassContext: () ->
        if @context.class.inClass
            if @lineHasToken 'INDENT'
                @context.class.classIndents++
            else if @lineHasToken 'OUTDENT'
                @context.class.classIndents--
                if @context.class.classIndents is 0
                    @context.class.inClass = false
                    @context.class.classIndents = null

            if @context.class.inClass and not @line.match( /^\s*$/ )
                @context.class.lastUnemptyLineInClass = @lineNumber
        else
            unless @line.match(/\\s*/)
                @context.class.lastUnemptyLineInClass = null

            if @lineHasToken 'CLASS'
                @context.class.inClass = true
                @context.class.lastUnemptyLineInClass = @lineNumber
                @context.class.classIndents = 0

        null

#
# A class that performs checks on the output of CoffeeScript's lexer.
#
class LexicalLinter

    constructor : (source, config) ->
        @source = source
        @tokens = CoffeeScript.tokens(source)
        @config = config
        @i = 0              # The index of the current token we're linting.
        @tokensByLine = {}  # A map of tokens by line.
        @arrayTokens = []   # A stack tracking the array token pairs.
        @parenTokens = []   # A stack tracking the parens token pairs.
        @callTokens = []    # A stack tracking the call token pairs.
        @lines = source.split('\n')
        @braceScopes = []   # A stack tracking keys defined in nexted scopes.

    # Return a list of errors encountered in the given source.
    lint : () ->
        errors = []

        for token, i in @tokens
            @i = i
            error = @lintToken(token)
            errors.push(error) if error
        errors

    # Return an error if the given token fails a lint check, false otherwise.
    lintToken : (token) ->
        [type, value, lineNumber] = token

        if typeof lineNumber == "object"
            if type == 'OUTDENT' or type == 'INDENT'
                lineNumber = lineNumber.last_line
            else
                lineNumber = lineNumber.first_line
        @tokensByLine[lineNumber] ?= []
        @tokensByLine[lineNumber].push(token)
        # CoffeeScript loses line numbers of interpolations and multi-line
        # regexes, so fake it by using the last line number we know.
        @lineNumber = lineNumber or @lineNumber or 0
        # Now lint it.
        switch type
            when "->"                     then @lintArrowSpacing(token)
            when "INDENT"                 then @lintIndentation(token)
            when "CLASS"                  then @lintClass(token)
            when "UNARY"                  then @lintUnary(token)
            when "{","}"                  then @lintBrace(token)
            when "IDENTIFIER"             then @lintIdentifier(token)
            when "++", "--"               then @lintIncrement(token)
            when "THROW"                  then @lintThrow(token)
            when "[", "]"                 then @lintArray(token)
            when "(", ")"                 then @lintParens(token)
            when "JS"                     then @lintJavascript(token)
            when "CALL_START", "CALL_END" then @lintCall(token)
            when "PARAM_START"            then @lintParam(token)
            when "@"                      then @lintStandaloneAt(token)
            when "+", "-"                 then @lintPlus(token)
            when "=", "MATH", "COMPARE", "LOGIC", "COMPOUND_ASSIGN"
                @lintMath(token)
            else null

    lintUnary: (token) ->
        if token[1] is 'new'
            # Find the last chained identifier, e.g. Bar in new foo.bar.Bar().
            identifierIndex = 1
            loop
                expectedIdentifier = @peek(identifierIndex)
                expectedCallStart  = @peek(identifierIndex + 1)
                if expectedIdentifier?[0] is 'IDENTIFIER'
                    if expectedCallStart?[0] is '.'
                        identifierIndex += 2
                        continue
                break

            # The callStart is generated if your parameters are all on the same
            # line with implicit parens, and if your parameters start on the
            # next line, but is missing if there are no params and no parens.
            if expectedIdentifier?[0] is 'IDENTIFIER' and expectedCallStart?
                if expectedCallStart[0] is 'CALL_START'
                    if expectedCallStart.generated
                        @createLexError('non_empty_constructor_needs_parens')
                else
                    @createLexError('empty_constructor_needs_parens')

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

    lintParens : (token) ->
        if token[0] == '('
            p1 = @peek(-1)
            n1 = @peek(1)
            n2 = @peek(2)
            # String interpolations start with '' + so start the type co-ercion,
            # so track if we're inside of one. This is most definitely not
            # 100% true but what else can we do?
            i = n1 and n2 and n1[0] == 'STRING' and n2[0] == '+'
            token.isInterpolation = i
            @parenTokens.push(token)
        else
            @parenTokens.pop()
        # We're not linting, just tracking interpolations.
        null

    isInInterpolation : () ->
        for t in @parenTokens
            return true if t.isInterpolation
        return false

    isInExtendedRegex : () ->
        for t in @callTokens
            return true if t.isRegex
        return false

    lintPlus : (token) ->
        # We can't check this inside of interpolations right now, because the
        # plusses used for the string type co-ercion are marked not spaced.
        return null if @isInInterpolation() or @isInExtendedRegex()

        p = @peek(-1)
        unaries = ['TERMINATOR', '(', '=', '-', '+', ',', 'CALL_START',
                    'INDEX_START', '..', '...', 'COMPARE', 'IF',
                    'THROW', 'LOGIC', 'POST_IF', ':', '[', 'INDENT',
                    'COMPOUND_ASSIGN', 'RETURN', 'MATH']
        isUnary = if not p then false else p[0] in unaries
        if (isUnary and token.spaced) or
                    (not isUnary and not token.spaced and not token.newLine)
            @createLexError('space_operators', {context: token[1]})
        else
            null

    lintMath: (token) ->
        if not token.spaced and not token.newLine
            @createLexError('space_operators', {context: token[1]})
        else
            null

    lintCall : (token) ->
        if token[0] == 'CALL_START'
            p = @peek(-1)
            # Track regex calls, to know (approximately) if we're in an
            # extended regex.
            token.isRegex = p and p[0] == 'IDENTIFIER' and p[1] == 'RegExp'
            @callTokens.push(token)
            if token.generated
                return @createLexError('no_implicit_parens')
            else
                return null
        else
            @callTokens.pop()
            return null

    lintParam : (token) ->
        nextType = @peek()[0]
        if nextType == 'PARAM_END'
            @createLexError('no_empty_param_list')
        else
            null

    lintIdentifier: (token) ->
        key = token[1]

        # Class names might not be in a scope
        return null if not @currentScope?
        nextToken = @peek(1)

        # Exit if this identifier isn't being assigned. A and B
        # are identifiers, but only A should be examined:
        # A = B
        return null if nextToken[1] isnt ':'
        previousToken = @peek(-1)

        # Assigning "@something" and "something" are not the same thing
        key = "@#{key}" if previousToken[0] == '@'

        # Added a prefix to not interfere with things like "constructor".
        key = "identifier-#{key}"
        if @currentScope[key]
            @createLexError('duplicate_key')
        else
            @currentScope[key] = token
            null

    lintBrace : (token) ->
        if token[0] == '{'
            @braceScopes.push @currentScope if @currentScope?
            @currentScope = {}
        else
            @currentScope = @braceScopes.pop()

        if token.generated and token[0] == '{'
            # Peek back to the last line break. If there is a class
            # definition, ignore the generated brace.
            i = -1
            loop
                t = @peek(i)
                if not t? or t[0] == 'TERMINATOR'
                    return @createLexError('no_implicit_braces')
                if t[0] == 'CLASS'
                    return null
                i -= 1
        else
            return null

    lintJavascript :(token) ->
        @createLexError('no_backticks')

    lintThrow : (token) ->
        [n1, n2] = [@peek(), @peek(2)]
        # Catch literals and string interpolations, which are wrapped in
        # parens.
        nextIsString = n1[0] == 'STRING' or (n1[0] == '(' and n2[0] == 'STRING')
        @createLexError('no_throwing_strings') if nextIsString

    lintIncrement : (token) ->
        attrs = {context : "found '#{token[0]}'"}
        @createLexError('no_plusplus', attrs)

    lintStandaloneAt: (token) ->
        nextToken = @peek()
        spaced = token.spaced
        isIdentifier = nextToken[0] == 'IDENTIFIER'
        isIndexStart = nextToken[0] == 'INDEX_START'
        isDot = nextToken[0] == '.'

        # https://github.com/jashkenas/coffee-script/issues/1601
        # @::foo is valid, but @:: behaves inconsistently and is planned for
        # removal. Technically @:: is a stand alone ::, but I think it makes
        # sense to group it into no_stand_alone_at
        if nextToken[0] == '::'
            protoProperty = @peek(2)
            isValidProtoProperty = protoProperty[0] == 'IDENTIFIER'

        if spaced or (not isIdentifier and not isIndexStart and
        not isDot and not isValidProtoProperty)
            @createLexError('no_stand_alone_at')


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
        previousSymbol = @peek(-1)?[0]
        isMultiline = previousSymbol in ['=', ',']

        # Summarize the indentation conditions we'd like to ignore
        ignoreIndent = isInterpIndent or isArrayIndent or isMultiline

        # Compensate for indentation in function invocations that span multiple
        # lines, which can be ignored.
        if @isChainedCall()
            currentLine = @lines[@lineNumber]
            prevNum = 1

            # keep going back until we are not at a comment or a blank line
            prevNum += 1 while (/^\s*(#|$)/.test(@lines[@lineNumber - prevNum]))
            previousLine = @lines[@lineNumber - prevNum]

            previousIndentation = previousLine.match(/^(\s*)/)[1].length
            # I don't know why, but when inside a function, you make a chained
            # call and define an inline callback as a parameter, the body of
            # that callback gets the indentation reported higher than it really
            # is. See issue #88
            # NOTE: Adding this line moved the cyclomatic complexity over the
            # limit, I'm not sure why
            numIndents = currentLine.match(/^(\s*)/)[1].length
            numIndents -= previousIndentation


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
        return null if token.newLine? or @peek()[0] in ['INDENT', 'EXTENDS']

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

    lintArrowSpacing : (token) ->
        # Throw error unless the following happens.
        #
        # We will take a look at the previous token to see
        # 1. That the token is properly spaced
        # 2. Wasn't generated by the CoffeeScript compiler
        # 3. That it is just indentation
        # 4. If the function declaration has no parameters
        # e.g. x(-> 3)
        #      x( -> 3)
        #
        # or a statement is wrapped in parentheses
        # e.g. (-> true)()
        #
        # we will accept either having a space or not having a space there.

        pp = @peek(-1)
        unless (token.spaced? or token.newLine?) and
               # Throw error unless the previous token...
               ((pp.spaced? or pp[0] is 'TERMINATOR') or #1
                pp.generated? or #2
                pp[0] is "INDENT" or #3
                (pp[1] is "(" and not pp.generated?)) #4
            @createLexError('arrow_spacing')
        else
            null

    createLexError : (rule, attrs = {}) ->
        attrs.lineNumber = @lineNumber + 1
        attrs.level = @config[rule].level
        attrs.line = @lines[@lineNumber]
        createError(rule, attrs)

    # Return the token n places away from the current token.
    peek : (n = 1) ->
        @tokens[@i + n] || null

    # Return true if the current token is inside of an array.
    inArray : () ->
        return @arrayTokens.length > 0

    # Return true if the current token is part of a property access
    # that is split across lines, for example:
    #   $('body')
    #       .addClass('foo')
    #       .removeClass('bar')
    isChainedCall : () ->
        # Get the index of the second most recent new line.
        lines = (i for token, i in @tokens[..@i] when token.newLine?)

        lastNewLineIndex = if lines then lines[lines.length - 2] else null

        # Bail out if there is no such token.
        return false if not lastNewLineIndex?

        # Otherwise, figure out if that token or the next is an attribute
        # look-up.
        tokens = [@tokens[lastNewLineIndex], @tokens[lastNewLineIndex + 1]]

        return !!(t for t in tokens when t and t[0] == '.').length


# A class that performs static analysis of the abstract
# syntax tree.
class ASTLinter

    constructor : (source, config) ->
        @source = source
        @config = config
        @errors = []

    lint : () ->
        try
            @node = CoffeeScript.nodes(@source)
        catch coffeeError
            @errors.push @_parseCoffeeScriptError(coffeeError)
            return @errors
        @lintNode(@node)
        @errors

    # returns the "complexity" value of the current node.
    getComplexity : (node) ->
        name = node.constructor.name
        complexity = if name in ['If', 'While', 'For', 'Try']
            1
        else if name == 'Op' and node.operator in ['&&', '||']
            1
        else if name == 'Switch'
            node.cases.length
        else
            0
        return complexity

    # Lint the AST node and return it's cyclomatic complexity.
    lintNode : (node, line) ->

        # Get the complexity of the current node.
        name = node.constructor.name
        complexity = @getComplexity(node)

        # Add the complexity of all child's nodes to this one.
        node.eachChild (childNode) =>
            nodeLine = childNode.locationData.first_line
            complexity += @lintNode(childNode, nodeLine) if childNode

        # If the current node is a function, and it's over our limit, add an
        # error to the list.
        rule = @config.cyclomatic_complexity

        if name == 'Code' and complexity >= rule.value
            attrs = {
                context: complexity + 1
                level: rule.level
                lineNumber: line + 1
                lineNumberEnd: node.locationData.last_line + 1
            }
            error = createError 'cyclomatic_complexity', attrs
            @errors.push error if error

        # Return the complexity for the benefit of parent nodes.
        return complexity

    _parseCoffeeScriptError : (coffeeError) ->
        rule = RULES['coffeescript_error']

        message = coffeeError.toString()

        # Parse the line number
        lineNumber = -1
        if coffeeError.location?
            lineNumber = coffeeError.location.first_line + 1
        else
            match = /line (\d+)/.exec message
            lineNumber = parseInt match[1], 10 if match?.length > 1
        attrs = {
            message: message
            level: rule.level
            lineNumber: lineNumber
        }
        return  createError 'coffeescript_error', attrs



# Merge default and user configuration.
mergeDefaultConfig = (userConfig) ->
    config = {}
    for rule, ruleConfig of RULES
        config[rule] = defaults(userConfig[rule], ruleConfig)
    return config

coffeelint.invertLiterate = (source) ->
    source = CoffeeScript.helpers.invertLiterate source
    # Strip the first 4 spaces from every line. After this the markdown is
    # commented and all of the other code should be at their natural location.
    newSource = ""
    for line in source.split "\n"
        if line.match(/^#/)
            # strip trailing space
            line = line.replace /\s*$/, ''
        # Strip the first 4 spaces of every line. This is how Markdown
        # indicates code, so in the end this pulls everything back to where it
        # would be indented if it hadn't been written in literate style.
        line = line.replace /^\s{4}/g, ''
        newSource += "#{line}\n"

    newSource

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
coffeelint.lint = (source, userConfig = {}, literate = false) ->
    source = @invertLiterate source if literate

    config = mergeDefaultConfig(userConfig)

    # Check ahead for inline enabled rules
    disabled_initially = []
    for l in source.split('\n')
        s = regexes.configStatement.exec(l)
        if s?.length > 2 and 'enable' in s
            for r in s[1..]
                unless r in ['enable','disable']
                    unless r of config and config[r].level in ['warn','error']
                        disabled_initially.push r
                        config[r] = { level: 'error' }

    # Do AST linting first so all compile errors are caught.
    astErrors = new ASTLinter(source, config).lint()

    # Do lexical linting.
    lexicalLinter = new LexicalLinter(source, config)
    lexErrors = lexicalLinter.lint()

    # Do line linting.
    tokensByLine = lexicalLinter.tokensByLine
    lineLinter = new LineLinter(source, config, tokensByLine)
    lineErrors = lineLinter.lint()

    # Sort by line number and return.
    errors = lexErrors.concat(lineErrors, astErrors)
    errors.sort((a, b) -> a.lineNumber - b.lineNumber)

    # Helper to remove rules from disabled list
    difference = (a, b) ->
        j = 0
        while j < a.length
            if a[j] in b
                a.splice(j, 1)
            else
                j++

    # Disable/enable rules for inline blocks
    all_errors = errors
    errors = []
    disabled = disabled_initially
    next_line = 0
    for i in [0...source.split('\n').length]
        for cmd of block_config
            rules = block_config[cmd][i]
            {
                'disable': ->
                    disabled = disabled.concat(rules)
                'enable': ->
                    difference(disabled, rules)
                    disabled = disabled_initially if rules.length is 0
            }[cmd]() if rules?
        # advance line and append relevant messages
        while next_line is i and all_errors.length > 0
            next_line = all_errors[0].lineNumber - 1
            e = all_errors[0]
            if e.lineNumber is i + 1 or not e.lineNumber?
                e = all_errors.shift()
                errors.push e unless e.rule in disabled

    block_config =
      'enable': {}
      'disable': {}

    errors
