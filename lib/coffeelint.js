(function() {
  /*
  CoffeeLint
  
  Copyright (c) 2011 Matthew Perpick.
  CoffeeLint is freely distributable under the MIT license.
  */
  var CoffeeScript, DEFAULT_CONFIG, LexicalLinter, MESSAGES, checkLines, coffeelint, defaults, extend, lineChecks, regexes,
    __slice = Array.prototype.slice;

  CoffeeScript = require('coffee-script');

  coffeelint = typeof exports !== "undefined" && exports !== null ? exports : this.coffeelint = {};

  coffeelint.VERSION = "0.0.3";

  DEFAULT_CONFIG = {
    tabs: false,
    trailing: false,
    lineLength: 80,
    indent: 2,
    camelCaseClasses: true
  };

  regexes = {
    trailingWhitespace: /\s+$/,
    indentation: /\S/,
    camelCase: /^[A-Z][a-zA-Z\d]*$/
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

  LexicalLinter = (function() {

    function LexicalLinter(source, config) {
      this.tokens = CoffeeScript.tokens(source);
      this.config = config;
      this.i = 0;
    }

    LexicalLinter.prototype.lint = function() {
      var error, errors, i, token, _len, _ref;
      errors = [];
      _ref = this.tokens;
      for (i = 0, _len = _ref.length; i < _len; i++) {
        token = _ref[i];
        if (!(!(token.generated != null))) continue;
        this.i = i;
        error = this.lintToken(token);
        if (error) errors.push(error);
      }
      return errors;
    };

    LexicalLinter.prototype.lintToken = function(token) {
      var line, type, value;
      type = token[0], value = token[1], line = token[2];
      switch (type) {
        case "INDENT":
          return this.lintIndentation(token);
        case "CLASS":
          return this.lintClass(token);
        default:
          return null;
      }
    };

    LexicalLinter.prototype.lintIndentation = function(token) {
      var error, inInterp, info, line, numIndents, previousToken, type;
      type = token[0], numIndents = token[1], line = token[2];
      previousToken = this.peek(-2);
      inInterp = previousToken && previousToken[0] === '+';
      if (this.config.indent && !inInterp && numIndents !== this.config.indent) {
        info = "Expected: " + this.config.indent + " Got: " + numIndents;
        return error = {
          reason: MESSAGES.INDENTATION_ERROR + info,
          line: line
        };
      } else {
        return null;
      }
    };

    LexicalLinter.prototype.lintClass = function(token) {
      var className, line, offset, type, value, _ref, _ref2;
      _ref = this.peek(), type = _ref[0], value = _ref[1], line = _ref[2];
      className = null;
      offset = 1;
      while (!className) {
        if (((_ref2 = this.peek(offset + 1)) != null ? _ref2[0] : void 0) === '.') {
          offset += 2;
        } else {
          className = this.peek(offset)[1];
        }
      }
      if (this.config.camelCaseClasses && !regexes.camelCase.test(className)) {
        return {
          reason: MESSAGES.INVALID_CLASS_NAME,
          line: line,
          evidence: className
        };
      } else {
        return null;
      }
    };

    LexicalLinter.prototype.peek = function(n) {
      if (n == null) n = 1;
      return this.tokens[this.i + n] || null;
    };

    return LexicalLinter;

  })();

  coffeelint.lint = function(source, userConfig) {
    var config, lexicalLinter;
    if (userConfig == null) userConfig = {};
    config = defaults(userConfig);
    if (config.tabs) config.indent = 1;
    lexicalLinter = new LexicalLinter(source, config);
    return checkLines(source, config).concat(lexicalLinter.lint());
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
    INDENTATION_ERROR: 'Indentation error',
    INVALID_CLASS_NAME: 'Invalid class name'
  };

}).call(this);
