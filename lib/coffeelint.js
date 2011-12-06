(function() {

  /*
  CoffeeLint
  
  Copyright (c) 2011 Matthew Perpick.
  CoffeeLint is freely distributable under the MIT license.
  */

  var DEFAULT_CONFIG, MESSAGES, coffeelint, defaults, extend, lineChecks, regexes;
  var __slice = Array.prototype.slice;

  coffeelint = typeof exports !== "undefined" && exports !== null ? exports : this.coffeelint = {};

  coffeelint.VERSION = "0.0.2";

  DEFAULT_CONFIG = {
    tabs: false,
    trailing: false,
    lineLength: 80
  };

  MESSAGES = {
    NO_TABS: 'Tabs are forbidden',
    TRAILING_WHITESPACE: 'Contains trailing whitespace',
    LINE_LENGTH_EXCEEDED: 'Maximum line length exceeded'
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

  coffeelint.lint = function(source, userConfig) {
    var check, config, error, errors, line, lineNumber, lines, rule, _len;
    if (userConfig == null) userConfig = {};
    config = defaults(userConfig);
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

}).call(this);
