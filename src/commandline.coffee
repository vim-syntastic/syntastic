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

    constructor : (errorReport, colorize=true) ->
        @errorReport = errorReport
        @colorize = colorize
        @ok = '✓'
        @warn = '⚡'
        @err = '✗'

    stylize : (message, styles...) ->
        return message if not @colorize
        map = {
            yellow: [33, 39],
            green: [32, 39],
            red: [31, 39]
        }
        return styles.reduce (m, s)  ->
            return "\u001b[" + map[s][0] + "m" + m + "\u001b[" + map[s][1] + "m"
        , message

    publish : () ->
        @reportPath(path, errors) for path, errors of @errorReport.paths
        summary = @errorReport.getSummary()
        @reportSummary(summary)
        return this

    reportSummary : (s) ->
        start = if s.errorCount > 0
            @stylize(@err, 'red')
        else if s.warningCount > 0
            @stylize @warn, 'yellow'
        else
            @stylize @ok, 'green'
        e = s.errorCount
        w = s.warningCount
        p = s.pathCount
        msg = "#{start} #{e} errors and #{w} warnings in #{p} files"
        @print @stylize(msg)

    reportPath : (path, errors) ->
        [overall, color] = if @errorReport.pathHasError(path)
            [@err, 'red']
        else if @errorReport.pathHasWarning(path)
            [@warn, 'yellow']
        else
            [@ok, 'green']
        @print(@stylize("#{overall} #{path}", color))
        for e in errors
            o = @stylize((if e.level == 'error' then @err else @warn), color)
            msg = "  #{o} line #{e.lineNumber} - #{e.message}."
            if e.context
                msg += " #{e.context}."
            @print(msg)

    print : (message) ->
        console.log message

# A reporter which reports nothing at all.
class NullReporter extends Reporter

    publish : (errorReport) ->
        null


# Return an error report from linting the given paths
lint = (paths, config) ->
    errorReport = new ErrorReport()
    paths.forEach (path) ->
        source = read(path)
        errors = coffeelint.lint(source, config)
        errorReport.paths[path] = errors
    return errorReport


# Declare command line options.
options = optimist
            .usage("Usage: coffeelint [options] source [...]")
            .alias("f", "file")
            .alias("h", "help")
            .alias("v", "version")
            .describe("f", "Specify a custom configuration file.")
            .describe("h", "Print help information.")
            .describe("v", "Print current version number.")
            .describe("r", "Recursively lint .coffee files in subdirectories.")
            .describe("nocolor", "Don't colorize output.")
            .boolean("nocolor")
            .boolean("r")

if options.argv.v
    console.log coffeelint.VERSION
    process.exit(0)
else if options.argv.h
    options.showHelp()
    process.exit(0)
else if options.argv._.length < 1
    options.showHelp()
    process.exit(1)
else
    # Find scripts to lint
    paths = options.argv._
    scripts = if options.argv.r then findCoffeeScripts(paths) else paths

    # Load configuration.
    configPath = options.argv.f
    config = if configPath then JSON.parse(read(configPath)) else {}

    # Lint the code.
    errorReport = lint(scripts, config)

    # Report on it
    colorize = not options.argv.nocolor
    reporter = new Reporter(errorReport, colorize)
    reporter.publish()
    process.exit(errorReport.getExitCode())

