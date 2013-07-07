###
CoffeeLint

Copyright (c) 2011 Matthew Perpick.
CoffeeLint is freely distributable under the MIT license.
###


path = require("path")
fs   = require("fs")
glob = require("glob")
optimist = require("optimist")
thisdir = path.dirname(fs.realpathSync(__filename))
coffeelint = require(path.join(thisdir, "..", "lib", "coffeelint"))
CoffeeScript = require 'coffee-script'


# Return the contents of the given file synchronously.
read = (path) ->
    realPath = fs.realpathSync(path)
    return fs.readFileSync(realPath).toString()

# Return a list of CoffeeScript's in the given paths.
findCoffeeScripts = (paths) ->
    files = []
    for p in paths
        if fs.statSync(p).isDirectory()
            # The glob library only uses forward slashes.
            files = files.concat(glob.sync("#{p}/**/*.coffee"))
        else
            files.push(p)
    return files

# A summary of errors in a CoffeeLint run.
class ErrorReport

    constructor : () ->
        @paths = {}

    getExitCode : () ->
        for path of @paths
            return 1 if @pathHasError(path)
        return 0

    getSummary : () ->
        pathCount = errorCount = warningCount = 0
        for path, errors of @paths
            pathCount++
            for error in errors
                errorCount++ if error.level == 'error'
                warningCount++ if error.level == 'warn'
        return {errorCount, warningCount, pathCount}

    getErrors : (path) ->
        return @paths[path]

    pathHasWarning : (path) ->
        return @_hasLevel(path, 'warn')

    pathHasError : (path) ->
        return @_hasLevel(path, 'error')

    hasError : () ->
        for path of @paths
            return true if @pathHasError(path)
        return false

    _hasLevel : (path, level) ->
        for error in @paths[path]
            return true if error.level == level
        return false


# Reports errors to the command line.
class Reporter

    constructor : (errorReport, colorize = true) ->
        @errorReport = errorReport
        @colorize = colorize
        @ok = '✓'
        @warn = '⚡'
        @err = '✗'

    stylize : (message, styles...) ->
        return message if not @colorize
        map = {
            bold  : [1,  22],
            yellow: [33, 39],
            green: [32, 39],
            red: [31, 39]
        }
        return styles.reduce (m, s)  ->
            return "\u001b[" + map[s][0] + "m" + m + "\u001b[" + map[s][1] + "m"
        , message

    publish : () ->
        paths = @errorReport.paths

        report  = ""
        report += @reportPath(path, errors) for path, errors of paths
        report += @reportSummary(@errorReport.getSummary())
        report += ""

        @print report if not options.argv.q or @errorReport.hasError()
        return this

    reportSummary : (s) ->
        start = if s.errorCount > 0
            "#{@err} #{@stylize("Lint!", 'red', 'bold')}"
        else if s.warningCount > 0
            "#{@warn} #{@stylize("Warning!", 'yellow', 'bold')}"
        else
            "#{@ok} #{@stylize("Ok!", 'green', 'bold')}"
        e = s.errorCount
        w = s.warningCount
        p = s.pathCount
        err = @plural('error', e)
        warn = @plural('warning', w)
        file = @plural('file', p)
        msg = "#{start} » #{e} #{err} and #{w} #{warn} in #{p} #{file}"
        return "\n" + @stylize(msg) + "\n"

    reportPath : (path, errors) ->
        [overall, color] = if hasError = @errorReport.pathHasError(path)
            [@err, 'red']
        else if hasWarning = @errorReport.pathHasWarning(path)
            [@warn, 'yellow']
        else
            [@ok, 'green']

        pathReport = ""
        if not options.argv.q or hasError
            pathReport += "  #{overall} #{@stylize(path, color, 'bold')}\n"

        for e in errors
            continue if options.argv.q and e.level != 'error'
            o = if e.level == 'error' then @err else @warn
            lineEnd = ""
            lineEnd = "-#{e.lineNumberEnd}" if e.lineNumberEnd?
            output = "#" + e.lineNumber + lineEnd

            pathReport += "     " +
                "#{o} #{@stylize(output, color)}: #{e.message}."
            pathReport += " #{e.context}." if e.context
            pathReport += "\n"

        pathReport

    print : (message) ->
        console.log message

    plural : (str, count) ->
        if count == 1 then str else "#{str}s"

class CSVReporter extends Reporter

    publish : () ->
        header = ["path","lineNumber", "lineNumberEnd", "level", "message"]
        @print header.join(",")
        for path, errors of @errorReport.paths
            for e in errors
                f = [
                    path
                    e.lineNumber
                    e.lineNumberEnd ? e.lineNumberEnd
                    e.level
                    e.message
                ]
                @print f.join(",")

class JSLintReporter extends Reporter

    publish : () ->
        @print "<?xml version=\"1.0\" encoding=\"utf-8\"?><jslint>"

        for path, errors of @errorReport.paths
            if errors.length
                @print "<file name=\"#{path}\">"

                for e in errors
                    @print """
                    <issue line="#{e.lineNumber}"
                            lineEnd=#{e.lineNumberEnd ? e.lineNumberEnd}
                            reason="[#{@escape(e.level)}] #{@escape(e.message)}"
                            evidence="#{@escape(e.context)}"/>
                    """
                @print "</file>"

        @print "</jslint>"

    escape : (msg) ->
        # Force msg to be a String
        msg = "" + msg
        unless msg
            return
        # Perhaps some other HTML Special Chars should be added here
        # But this are the XML Special Chars listed in Wikipedia
        replacements = [
            [/&/g, "&amp;"]
            [/"/g, "&quot;"]
            [/</g, "&lt;"]
            [/>/g, "&gt;"]
            [/'/g, "&apos;"]
            ]

        for r in replacements
            msg = msg.replace r[0], r[1]

        msg

# Return an error report from linting the given paths.
lintFiles = (paths, config) ->
    errorReport = new ErrorReport()
    for path in paths
        source = read(path)
        literate = CoffeeScript.helpers.isLiterate path

        errorReport.paths[path] = coffeelint.lint(source, config, literate)
    return errorReport

# Return an error report from linting the given coffeescript source.
lintSource = (source, config, literate = false) ->
    errorReport = new ErrorReport()
    errorReport.paths["stdin"] = coffeelint.lint(source, config, literate)
    return errorReport

# Publish the error report and exit with the appropriate status.
reportAndExit = (errorReport, options) ->
    reporter = if options.argv.jslint
        new JSLintReporter(errorReport)
    else if options.argv.csv
        new CSVReporter(errorReport)
    else
        colorize = not options.argv.nocolor
        new Reporter(errorReport, colorize)
    reporter.publish()

    process.on 'exit', () ->
        process.exit errorReport.getExitCode()

# Declare command line options.
options = optimist
            .usage("Usage: coffeelint [options] source [...]")
            .alias("f", "file")
            .alias("h", "help")
            .alias("v", "version")
            .alias("s", "stdin")
            .alias("q", "quiet")
            .describe("f", "Specify a custom configuration file.")
            .describe("makeconfig", "Prints a default config file")
            .describe("noconfig",
                "Ignores the environment variable COFFEELINT_CONFIG.")
            .describe("h", "Print help information.")
            .describe("v", "Print current version number.")
            .describe("r", "Recursively lint .coffee files in subdirectories.")
            .describe("csv", "Use the csv reporter.")
            .describe("jslint", "Use the JSLint XML reporter.")
            .describe("nocolor", "Don't colorize the output")
            .describe("s", "Lint the source from stdin")
            .describe("q", "Only print errors.")
            .describe("literate",
                "Used with --stdin to process as Literate CoffeeScript")
            .boolean("csv")
            .boolean("jslint")
            .boolean("nocolor")
            .boolean("noconfig")
            .boolean("makeconfig")
            .boolean("literate")
            .boolean("r")
            .boolean("s")
            .boolean("q", "Print errors only.")

if options.argv.v
    console.log coffeelint.VERSION
    process.exit(0)
else if options.argv.h
    options.showHelp()
    process.exit(0)
else if options.argv.makeconfig
    console.log JSON.stringify coffeelint.RULES,
        ((k,v) -> v unless k in ['message', 'description']), 4
else if options.argv._.length < 1 and not options.argv.s
    options.showHelp()
    process.exit(1)

else
    # Load configuration.
    config = {}
    unless options.argv.noconfig
        # path.existsSync was moved to fs.existsSync node 0.6 -> 0.8
        existsFn = fs.existsSync ? path.existsSync
        if options.argv.f
            config = JSON.parse read options.argv.f
        else if (process.env.COFFEELINT_CONFIG and
        existsFn process.env.COFFEELINT_CONFIG)
            config = JSON.parse(read(process.env.COFFEELINT_CONFIG))

    if options.argv.s
        # Lint from stdin
        data = ''
        stdin = process.openStdin()
        stdin.on 'data', (buffer) ->
            data += buffer.toString() if buffer
        stdin.on 'end', ->
            errorReport = lintSource(data, config, options.argv.literate)
            reportAndExit errorReport, options
    else
        # Find scripts to lint.
        paths = options.argv._
        scripts = if options.argv.r then findCoffeeScripts(paths) else paths

        # Lint the code.
        errorReport = lintFiles(scripts, config, options.argv.literate)
        reportAndExit errorReport, options
