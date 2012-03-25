###
CoffeeLint

Copyright (c) 2011 Matthew Perpick.
CoffeeLint is freely distributable under the MIT license.
###


# Load dependencies.
path = require("path")
fs = require("fs")
optimist = require("optimist")
thisdir = path.dirname(fs.realpathSync(__filename))
coffeelint = require(path.join(thisdir, "..", "lib", "coffeelint"))


# Colorize the given message.
stylize = (message, styles) ->
    map =
        bold: [ 1, 22 ]
        yellow: [ 33, 39 ]
        green: [ 32, 39 ]
        red: [ 31, 39 ]

    return styles.reduce((m, style) ->
        "\u001b[" + map[style][0] + "m" + m + "\u001b[" + map[style][1] + "m"
    , message)

# Report and error on the console.
reportError = (path, error, colorize) ->
    fields = [ path + "#" + error.lineNumber, error.level, error.message ]
    fields.push error.context  if error.context
    console.warn fields.join(" : ")

# Report a success message.
reportSuccess = (message, colorize) ->
    message = stylize(message, [ "bold", "green" ]) if colorize
    console.log message

# Return the contents of the given path synchronously.
read = (path) ->
    realPath = fs.realpathSync(path)
    return fs.readFileSync(realPath).toString()

# Lint the given
lint = (paths, configPath, colorize) ->
    config = (if (configPath) then JSON.parse(read(configPath)) else {})
    foundError = false
    foundWarning = false
    paths.forEach (path) ->
        source = read(path)
        coffeelint.lint(source, config).forEach (error) ->
            reportError path, error
            foundError = foundError or error.level is "error"
            foundWarning = foundWarning or error.level is "warn"

    if not foundError and not foundWarning
        reportSuccess("Lint free!", colorize)

    return if foundError then 1 else 0

# Declare command line options.
options = optimist
            .usage("Usage: coffeelint [options] source [...]")
            .alias("f", "file")
            .alias("h", "help")
            .alias("v", "version")
            .describe("f", "Specify a custom configuration file.")
            .describe("h", "Print help information.")
            .describe("v", "Print current version number.")
            .describe("nocolor", "Don't colorize output.")
            .boolean("nocolor")

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
    paths = options.argv._
    configPath = options.argv.f
    colorize = not options.argv.nocolor
    returnCode = lint(paths, configPath, colorize)
    process.exit returnCode

