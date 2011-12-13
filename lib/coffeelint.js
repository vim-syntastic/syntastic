(function() {

  /*
  CoffeeLint
  
  Copyright (c) 2011 Matthew Perpick.
  CoffeeLint is freely distributable under the MIT license.
  */

  var CoffeeScript, DEFAULT_CONFIG, LexicalLinter, LineLinter, MESSAGES, coffeelint, defaults, extend, regexes;
  var __slice = Array.prototype.slice;

  coffeelint = {};

  if (typeof exports !== "undefined" && exports !== null) {
    coffeelint = exports;
    CoffeeScript = require('coffee-script');
  } else {
    this.coffeelint = coffeelint;
    CoffeeScript = this.CoffeeScript;
  }

  coffeelint.VERSION = "0.0.3";

  DEFAULT_CONFIG = {
    tabs: false,
    trailing: false,
    lineLength: 80,
    indent: 2,
    camelCaseClasses: true,
    trailingSemicolons: false
  };

  regexes = {
    trailingWhitespace: /\s+$/,
    indentation: /\S/,
    camelCase: /^[A-Z][a-zA-Z\d]*$/,
    trailingSemicolon: /;$/
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

  LineLinter = (function() {

    function LineLinter(source, config, tokensByLine) {
      this.source = source;
      this.config = config;
      this.line = null;
      this.lineNumber = 0;
      this.tokensByLine = tokensByLine;
    }

    LineLinter.prototype.lint = function() {
      var error, errors, line, lineNumber, _len, _ref;
      errors = [];
      _ref = this.source.split('\n');
      for (lineNumber = 0, _len = _ref.length; lineNumber < _len; lineNumber++) {
        line = _ref[lineNumber];
        this.lineNumber = lineNumber;
        this.line = line;
        error = this.lintLine();
        if (error) {
          error.line = this.lineNumber;
          error.evidence = this.line;
          if (error) errors.push(error);
        }
      }
      return errors;
    };

    LineLinter.prototype.lintLine = function() {
      var error;
      error = this.checkTabs() || this.checkTrailingWhitespace() || this.checkLineLength() || this.checkTrailingSemicolon();
      return error;
    };

    LineLinter.prototype.checkTabs = function() {
      var indentation;
      if (this.config.tabs) return null;
      indentation = this.line.split(regexes.indentation)[0];
      if (this.lineHasToken() && ~indentation.indexOf('\t')) {
        return {
          character: 0,
          reason: MESSAGES.NO_TABS
        };
      } else {
        return null;
      }
    };

    LineLinter.prototype.lineHasToken = function() {
      return this.tokensByLine[this.lineNumber] != null;
    };

    LineLinter.prototype.getLineTokens = function() {
      return this.tokensByLine[this.lineNumber] || [];
    };

    LineLinter.prototype.checkTrailingWhitespace = function() {
      if (!this.config.trailing && regexes.trailingWhitespace.test(this.line)) {
        return {
          character: this.line.length,
          reason: MESSAGES.TRAILING_WHITESPACE
        };
      }
    };

    LineLinter.prototype.checkLineLength = function() {
      var lineLength;
      lineLength = this.config.lineLength;
      if (lineLength && lineLength < this.line.length) {
        return {
          character: 0,
          reason: MESSAGES.LINE_LENGTH_EXCEEDED
        };
      }
    };

    LineLinter.prototype.checkTrailingSemicolon = function() {
      var first, hasNewLine, hasSemicolon, last, _i, _ref;
      if (this.config.trailingSemiColons) return null;
      hasSemicolon = regexes.trailingSemicolon.test(this.line);
      _ref = this.getLineTokens(), first = 2 <= _ref.length ? __slice.call(_ref, 0, _i = _ref.length - 1) : (_i = 0, []), last = _ref[_i++];
      hasNewLine = last && (last.newLine != null);
      if (hasSemicolon && !hasNewLine && this.lineHasToken()) {
        return {
          reason: "Unnecessary semicolon"
        };
      } else {
        return null;
      }
    };

    return LineLinter;

  })();

  LexicalLinter = (function() {

    function LexicalLinter(source, config) {
      this.source = source;
      this.tokens = CoffeeScript.tokens(source);
      this.config = config;
      this.i = 0;
      this.tokensByLine = {};
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
      var line, type, value, _base, _ref;
      type = token[0], value = token[1], line = token[2];
      if ((_ref = (_base = this.tokensByLine)[line]) == null) _base[line] = [];
      this.tokensByLine[line].push(token);
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
    var config, errors, lexErrors, lexicalLinter, lineErrors, lineLinter, tokensByLine;
    if (userConfig == null) userConfig = {};
    config = defaults(userConfig);
    if (config.tabs) config.indent = 1;
    lexicalLinter = new LexicalLinter(source, config);
    lexErrors = lexicalLinter.lint();
    tokensByLine = lexicalLinter.tokensByLine;
    lineLinter = new LineLinter(source, config, tokensByLine);
    lineErrors = lineLinter.lint();
    errors = lexErrors.concat(lineErrors);
    errors.sort(function(a, b) {
      return a.line - b.line;
    });
    return errors;
  };

  MESSAGES = {
    NO_TABS: 'Tabs are forbidden',
    TRAILING_WHITESPACE: 'Contains trailing whitespace',
    LINE_LENGTH_EXCEEDED: 'Maximum line length exceeded',
    INDENTATION_ERROR: 'Indentation error',
    INVALID_CLASS_NAME: 'Invalid class name'
  };

}).call(this);
