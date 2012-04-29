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


# Return the contents of the given file synchronously.
read = (path) ->
    realPath = fs.realpathSync(path)
    return fs.readFileSync(realPath).toString()

# Return a list of CoffeeScript's in the given paths.
findCoffeeScripts = (paths) ->
    files = []
    for p in paths
        if fs.statSync(p).isDirectory()
            files = files.concat(glob.sync(path.join(p, "**", "*.coffee")))
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

    _hasLevel : (path, level) ->
        for error in @paths[path]
            return true if error.level == level
        return false


# Reports errors to the command line.
class Reporter

    constructor : (errorReport) ->
        @errorReport = errorReport
        @ok = '✓'
        @warn = '⚡'
        @err = '✗'

    stylize : (message, styles...) ->
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
        @print ""
        @reportPath(path, errors) for path, errors of @errorReport.paths
        summary = @errorReport.getSummary()
        @reportSummary(summary)
        @print ""
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
        @print "\n" + @stylize(msg)

    reportPath : (path, errors) ->
        [overall, color] = if @errorReport.pathHasError(path)
            [@err, 'red']
        else if @errorReport.pathHasWarning(path)
            [@warn, 'yellow']
        else
            [@ok, 'green']
        @print "  #{overall} #{@stylize(path, color, 'bold')}"
        for e in errors
            o = if e.level == 'error' then @err else @warn
            msg = "     " +
                    "#{o} #{@stylize("#" + e.lineNumber, color)}: #{e.message}."
            msg += " #{e.context}." if e.context
            @print(msg)

    print : (message) ->
        console.log message

    plural : (str, count) ->
        if count == 1 then str else "#{str}s"

class CSVReporter extends Reporter

    publish : () ->
        for path, errors of @errorReport.paths
            for e in errors
                f = [path, e.lineNumber, e.level, e.message]
                @print f.join(",")

# Return an error report from linting the given paths.
lintFiles = (paths, config) ->
    errorReport = new ErrorReport()
    for path in paths
        errorReport.paths[path] = lintSource(read(path), config).paths["src"]
    return errorReport

# Return an error report from linting the given coffeescript source.
lintSource = (source, config) ->
    errorReport = new ErrorReport()
    errorReport.paths["src"] = coffeelint.lint(source, config)
    return errorReport

# Publish the error report and exit with the appropriate status.
reportAndExit = (errorReport, options) ->
    ReporterClass = if options.argv.csv then CSVReporter else Reporter
    reporter = new ReporterClass(errorReport)
    reporter.publish()
    process.exit(errorReport.getExitCode())

# Declare command line options.
options = optimist
            .usage("Usage: coffeelint [options] source [...]")
            .alias("f", "file")
            .alias("h", "help")
            .alias("v", "version")
            .alias("s", "stdin")
            .describe("f", "Specify a custom configuration file.")
            .describe("h", "Print help information.")
            .describe("v", "Print current version number.")
            .describe("r", "Recursively lint .coffee files in subdirectories.")
            .describe("csv", "Use the csv reporter.")
            .describe("s", "Use stdin instead of a filepath")
            .boolean("csv")
            .boolean("r")
            .boolean("s")

if options.argv.v
    console.log coffeelint.VERSION
    process.exit(0)
else if options.argv.h
    options.showHelp()
    process.exit(0)
else if options.argv._.length < 1 and not options.argv.s
    options.showHelp()
    process.exit(1)
else
    # Load configuration.
    configPath = options.argv.f
    config = if configPath then JSON.parse(read(configPath)) else {}

    if options.argv.s
        # Lint from stdin
        data = ''
        process.openStdin()
            .on 'data', (buffer) ->
                data += buffer.toString() if buffer
            .on 'end', ->
                errorReport = lintSource(data, config)
                reportAndExit errorReport, options
    else
        # Find scripts to lint.
        paths = options.argv._
        scripts = if options.argv.r then findCoffeeScripts(paths) else paths

        # Lint the code.
        errorReport = lintFiles(scripts, config)
        reportAndExit errorReport, options
        

