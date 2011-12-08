(function() {

  /*
  CoffeeLint
  
  Copyright (c) 2011 Matthew Perpick.
  CoffeeLint is freely distributable under the MIT license.
  */

  var DEFAULT_CONFIG, MESSAGES, checkLines, checkTokens, coffeelint, coffeescript, defaults, extend, lexChecks, lineChecks, regexes;
  var __slice = Array.prototype.slice;

  coffeescript = require('coffee-script');

  coffeelint = typeof exports !== "undefined" && exports !== null ? exports : this.coffeelint = {};

  coffeelint.VERSION = "0.0.3";

  DEFAULT_CONFIG = {
    tabs: false,
    trailing: false,
    lineLength: 80,
    indent: 2
  };

  regexes = {
    trailingWhitespace: /\s+$/,
    indentation: /\S/
  };

  extend = function() {
    var destination, k, source, sources, v, _i, _len;
    destination = arguments[0], sources = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    for (_i = 0, _len = sources.length; _i < _len; _i++) {
      source = sources[_i];
      for (k in source) {
        v = source[k];
        destination[k] = v;
      }
    }
    return destination;
  };

  defaults = function(userConfig) {
    return extend({}, DEFAULT_CONFIG, userConfig);
  };

  checkLines = function(source, config) {
    var check, error, errors, line, lineNumber, lines, rule, _len;
    errors = [];
    lines = source.split('\n');
    for (lineNumber = 0, _len = lines.length; lineNumber < _len; lineNumber++) {
      line = lines[lineNumber];
      for (rule in lineChecks) {
        check = lineChecks[rule];
        error = check(line, config);
        if (error) {
          error.line = lineNumber;
          error.evidence = line;
          errors.push(error);
        }
      }
    }
    return errors;
  };

  checkTokens = function(source, config) {
    var check, error, errors, line, token, tokens, type, value, _i, _len;
    tokens = coffeescript.tokens(source);
    errors = [];
    for (_i = 0, _len = tokens.length; _i < _len; _i++) {
      token = tokens[_i];
      if (!(!(token.generated != null))) continue;
      type = token[0], value = token[1], line = token[2];
      check = lexChecks[type];
      error = check ? check(config, token) : null;
      if (error) {
        error.line = line;
        errors.push(error);
      }
    }
    return errors;
  };

  coffeelint.lint = function(source, userConfig) {
    var config;
    if (userConfig == null) userConfig = {};
    config = defaults(userConfig);
    if (config.tabs) config.indent = 1;
    return checkLines(source, config).concat(checkTokens(source, config));
  };

  lexChecks = {
    INDENT: function(config, token) {
      var error, info, line, type, value;
      type = token[0], value = token[1], line = token[2];
      if (config.indent && value !== config.indent) {
        info = " Expected: " + config.indent + " Got: " + value;
        return error = {
          reason: MESSAGES.INDENTATION_ERROR + info
        };
      } else {
        return null;
      }
    }
  };

  lineChecks = {
    checkTabs: function(line, config) {
      var indentation;
      if (config.tabs) return null;
      indentation = line.split(regexes.indentation)[0];
      if (~indentation.indexOf('\t')) {
        return {
          character: 0,
          reason: MESSAGES.NO_TABS
        };
      }
    },
    checkTrailingWhitespace: function(line, config) {
      if (!config.trailing && regexes.trailingWhitespace.test(line)) {
        return {
          character: line.length,
          reason: MESSAGES.TRAILING_WHITESPACE
        };
      } else {
        return null;
      }
    },
    checkLineLength: function(line, config) {
      var lineLength;
      lineLength = config.lineLength;
      if (lineLength && lineLength < line.length) {
        return {
          character: 0,
          reason: MESSAGES.LINE_LENGTH_EXCEEDED
        };
      } else {
        return null;
      }
    }
  };

  MESSAGES = {
    NO_TABS: 'Tabs are forbidden',
    TRAILING_WHITESPACE: 'Contains trailing whitespace',
    LINE_LENGTH_EXCEEDED: 'Maximum line length exceeded',
    INDENTATION_ERROR: 'Indentation error'
  };

}).call(this);
