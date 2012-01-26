
/*
CoffeeLint

Copyright (c) 2011 Matthew Perpick.
CoffeeLint is freely distributable under the MIT license.
*/

(function() {
  var CoffeeScript, ERROR, IGNORE, LexicalLinter, LineLinter, RULES, WARN, coffeelint, createError, defaults, extend, mergeDefaultConfig, regexes,
    __slice = Array.prototype.slice;

  coffeelint = {};

  if (typeof exports !== "undefined" && exports !== null) {
    coffeelint = exports;
    CoffeeScript = require('coffee-script');
  } else {
    this.coffeelint = coffeelint;
    CoffeeScript = this.CoffeeScript;
  }

  coffeelint.VERSION = "0.2.0";

  ERROR = 'error';

  WARN = 'warn';

  IGNORE = 'ignore';

  RULES = {
    no_tabs: {
      level: ERROR,
      message: 'Line contains tab indentation'
    },
    no_trailing_whitespace: {
      level: ERROR,
      message: 'Line ends with trailing whitespace'
    },
    max_line_length: {
      value: 80,
      level: ERROR,
      message: 'Line exceeds maximum allowed length'
    },
    camel_case_classes: {
      level: ERROR,
      message: 'Class names should be camel cased'
    },
    indentation: {
      value: 2,
      level: ERROR,
      message: 'Line contains inconsistent indentation'
    },
    no_implicit_braces: {
      level: IGNORE,
      message: 'Implicit braces are forbidden'
    },
    no_trailing_semicolons: {
      level: ERROR,
      message: 'Line contains a trailing semicolon'
    },
    no_plusplus: {
      level: IGNORE,
      message: 'The increment and decrement operators are forbidden'
    },
    no_throwing_strings: {
      level: ERROR,
      message: 'Throwing strings is forbidden'
    }
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

  defaults = function(source, defaults) {
    return extend({}, defaults, source);
  };

  createError = function(rule, attrs) {
    if (attrs == null) attrs = {};
    attrs.rule = rule;
    return defaults(attrs, RULES[rule]);
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
        if (error) errors.push(error);
      }
      return errors;
    };

    LineLinter.prototype.lintLine = function() {
      return this.checkTabs() || this.checkTrailingWhitespace() || this.checkLineLength() || this.checkTrailingSemicolon();
    };

    LineLinter.prototype.checkTabs = function() {
      var indent;
      indent = this.line.split(regexes.indentation)[0];
      if (this.lineHasToken() && ~indent.indexOf('\t')) {
        return this.createLineError('no_tabs');
      } else {
        return null;
      }
    };

    LineLinter.prototype.checkTrailingWhitespace = function() {
      if (regexes.trailingWhitespace.test(this.line)) {
        return this.createLineError('no_trailing_whitespace');
      } else {
        return null;
      }
    };

    LineLinter.prototype.checkLineLength = function() {
      var max, rule, _ref;
      rule = 'max_line_length';
      max = (_ref = this.config[rule]) != null ? _ref.value : void 0;
      if (max && max < this.line.length) {
        return this.createLineError(rule);
      } else {
        return null;
      }
    };

    LineLinter.prototype.checkTrailingSemicolon = function() {
      var first, hasNewLine, hasSemicolon, last, _i, _ref;
      hasSemicolon = regexes.trailingSemicolon.test(this.line);
      _ref = this.getLineTokens(), first = 2 <= _ref.length ? __slice.call(_ref, 0, _i = _ref.length - 1) : (_i = 0, []), last = _ref[_i++];
      hasNewLine = last && (last.newLine != null);
      if (hasSemicolon && !hasNewLine && this.lineHasToken()) {
        return this.createLineError('no_trailing_semicolons');
      } else {
        return null;
      }
    };

    LineLinter.prototype.createLineError = function(rule) {
      var attrs, level, _ref;
      level = (_ref = this.config[rule]) != null ? _ref.level : void 0;
      if (level !== IGNORE) {
        attrs = {
          lineNumber: this.lineNumber + 1,
          level: level
        };
        return createError(rule, attrs);
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

    return LineLinter;

  })();

  LexicalLinter = (function() {

    function LexicalLinter(source, config) {
      this.source = source;
      this.tokens = CoffeeScript.tokens(source);
      this.config = config;
      this.i = 0;
      this.tokensByLine = {};
      this.arrayTokens = [];
    }

    LexicalLinter.prototype.lint = function() {
      var error, errors, i, token, _len, _ref;
      errors = [];
      _ref = this.tokens;
      for (i = 0, _len = _ref.length; i < _len; i++) {
        token = _ref[i];
        this.i = i;
        error = this.lintToken(token);
        if (error) errors.push(error);
      }
      return errors;
    };

    LexicalLinter.prototype.lintToken = function(token) {
      var lineNumber, type, value, _base;
      type = token[0], value = token[1], lineNumber = token[2];
      if ((_base = this.tokensByLine)[lineNumber] == null) _base[lineNumber] = [];
      this.tokensByLine[lineNumber].push(token);
      this.lineNumber = lineNumber;
      switch (type) {
        case "INDENT":
          return this.lintIndentation(token);
        case "CLASS":
          return this.lintClass(token);
        case "{":
          return this.lintBrace(token);
        case "++":
        case "--":
          return this.lintUnaryAddition(token);
        case "--":
          return this.lintUnaryAddition(token);
        case "THROW":
          return this.lintThrow(token);
        case "[":
        case "]":
          return this.lintArray(token);
        default:
          return null;
      }
    };

    LexicalLinter.prototype.lintArray = function(token) {
      if (token[0] === '[') {
        this.arrayTokens.push(token);
      } else if (token[0] === ']') {
        this.arrayTokens.pop();
      }
      return null;
    };

    LexicalLinter.prototype.lintBrace = function(token) {
      if (token.generated) {
        return this.createLexError('no_implicit_braces');
      } else {
        return null;
      }
    };

    LexicalLinter.prototype.lintThrow = function(token) {
      var n1, n2, nextIsString, _ref;
      _ref = [this.peek(), this.peek(2)], n1 = _ref[0], n2 = _ref[1];
      nextIsString = n1[0] === 'STRING' || (n1[0] === '(' && n2[0] === 'STRING');
      if (nextIsString) return this.createLexError('no_throwing_strings');
    };

    LexicalLinter.prototype.lintUnaryAddition = function(token) {
      var attrs;
      attrs = {
        context: "found '" + token[0] + "'"
      };
      return this.createLexError('no_plusplus', attrs);
    };

    LexicalLinter.prototype.lintIndentation = function(token) {
      var context, expected, ignoreIndent, isArrayIndent, isInterpIndent, isMultiline, lineNumber, numIndents, previous, previousSymbol, type, _ref;
      type = token[0], numIndents = token[1], lineNumber = token[2];
      if (token.generated != null) return null;
      previous = this.peek(-2);
      isInterpIndent = previous && previous[0] === '+';
      previous = this.peek(-1);
      isArrayIndent = this.inArray() && (previous != null ? previous.newLine : void 0);
      previousSymbol = (_ref = this.peek(-1)) != null ? _ref[0] : void 0;
      isMultiline = previousSymbol === '=' || previousSymbol === ',';
      ignoreIndent = isInterpIndent || isArrayIndent || isMultiline;
      expected = this.config['indentation'].value;
      if (!ignoreIndent && numIndents !== expected) {
        context = ("Expected " + expected + " ") + ("got " + numIndents);
        return this.createLexError('indentation', {
          context: context
        });
      } else {
        return null;
      }
    };

    LexicalLinter.prototype.lintClass = function(token) {
      var attrs, className, lineNumber, offset, type, value, _ref, _ref2;
      _ref = this.peek(), type = _ref[0], value = _ref[1], lineNumber = _ref[2];
      className = null;
      offset = 1;
      while (!className) {
        if (((_ref2 = this.peek(offset + 1)) != null ? _ref2[0] : void 0) === '.') {
          offset += 2;
        } else {
          className = this.peek(offset)[1];
        }
      }
      if (!regexes.camelCase.test(className)) {
        attrs = {
          context: "class name: " + className
        };
        return this.createLexError('camel_case_classes', attrs);
      } else {
        return null;
      }
    };

    LexicalLinter.prototype.createLexError = function(rule, attrs) {
      var level, _ref;
      if (attrs == null) attrs = {};
      level = (_ref = this.config[rule]) != null ? _ref.level : void 0;
      if (level !== IGNORE) {
        attrs.lineNumber = this.lineNumber + 1;
        attrs.level = level;
        return createError(rule, attrs);
      } else {
        return null;
      }
    };

    LexicalLinter.prototype.peek = function(n) {
      if (n == null) n = 1;
      return this.tokens[this.i + n] || null;
    };

    LexicalLinter.prototype.inArray = function() {
      return this.arrayTokens.length > 0;
    };

    return LexicalLinter;

  })();

  mergeDefaultConfig = function(userConfig) {
    var config, rule, ruleConfig;
    config = {};
    for (rule in RULES) {
      ruleConfig = RULES[rule];
      config[rule] = defaults(userConfig[rule], ruleConfig);
    }
    return config;
  };

  coffeelint.lint = function(source, userConfig) {
    var config, errors, lexErrors, lexicalLinter, lineErrors, lineLinter, tokensByLine;
    if (userConfig == null) userConfig = {};
    config = mergeDefaultConfig(userConfig);
    lexicalLinter = new LexicalLinter(source, config);
    lexErrors = lexicalLinter.lint();
    tokensByLine = lexicalLinter.tokensByLine;
    lineLinter = new LineLinter(source, config, tokensByLine);
    lineErrors = lineLinter.lint();
    errors = lexErrors.concat(lineErrors);
    errors.sort(function(a, b) {
      return a.lineNumber - b.lineNumber;
    });
    return errors;
  };

}).call(this);
