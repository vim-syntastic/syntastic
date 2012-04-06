
/*
CoffeeLint

Copyright (c) 2011 Matthew Perpick.
CoffeeLint is freely distributable under the MIT license.
*/

(function() {
  var ASTLinter, CoffeeScript, ERROR, IGNORE, LexicalLinter, LineLinter, RULES, WARN, coffeelint, createError, defaults, extend, mergeDefaultConfig, regexes,
    __slice = Array.prototype.slice,
    __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  coffeelint = {};

  if (typeof exports !== "undefined" && exports !== null) {
    coffeelint = exports;
    CoffeeScript = require('coffee-script');
  } else {
    this.coffeelint = coffeelint;
    CoffeeScript = this.CoffeeScript;
  }

  coffeelint.VERSION = "0.4.0";

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
    },
    cyclomatic_complexity: {
      value: 10,
      level: IGNORE,
      message: 'The cyclomatic complexity is too damn high'
    },
    no_backticks: {
      level: ERROR,
      message: 'Backticks are forbidden'
    },
    line_endings: {
      level: IGNORE,
      value: 'unix',
      message: 'Line contains incorrect line endings'
    }
  };

  regexes = {
    trailingWhitespace: /[^\s]+[\t ]+\r?$/,
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
    var level;
    if (attrs == null) attrs = {};
    level = attrs.level;
    if (level !== IGNORE && level !== WARN && level !== ERROR) {
      throw new Error("unknown level " + level);
    }
    if (level === ERROR || level === WARN) {
      attrs.rule = rule;
      return defaults(attrs, RULES[rule]);
    } else {
      return null;
    }
  };

  LineLinter = (function() {

    function LineLinter(source, config, tokensByLine) {
      this.source = source;
      this.config = config;
      this.line = null;
      this.lineNumber = 0;
      this.tokensByLine = tokensByLine;
      this.lines = this.source.split('\n');
      this.lineCount = this.lines.length;
    }

    LineLinter.prototype.lint = function() {
      var error, errors, line, lineNumber, _len, _ref;
      errors = [];
      _ref = this.lines;
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
      return this.checkTabs() || this.checkTrailingWhitespace() || this.checkLineLength() || this.checkTrailingSemicolon() || this.checkLineEndings();
    };

    LineLinter.prototype.checkTabs = function() {
      var indentation;
      indentation = this.line.split(regexes.indentation)[0];
      if (this.lineHasToken() && __indexOf.call(indentation, '\t') >= 0) {
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

    LineLinter.prototype.checkLineEndings = function() {
      var ending, lastChar, rule, valid, _ref;
      rule = 'line_endings';
      ending = (_ref = this.config[rule]) != null ? _ref.value : void 0;
      if (!ending || this.isLastLine() || !this.line) return null;
      lastChar = this.line[this.line.length - 1];
      valid = (function() {
        if (ending === 'windows') {
          return lastChar === '\r';
        } else if (ending === 'unix') {
          return lastChar !== '\r';
        } else {
          throw new Error("unknown line ending type: " + ending);
        }
      })();
      if (!valid) {
        return this.createLineError(rule, {
          context: "Expected " + ending
        });
      } else {
        return null;
      }
    };

    LineLinter.prototype.createLineError = function(rule, attrs) {
      var _ref;
      if (attrs == null) attrs = {};
      attrs.lineNumber = this.lineNumber + 1;
      attrs.level = (_ref = this.config[rule]) != null ? _ref.level : void 0;
      return createError(rule, attrs);
    };

    LineLinter.prototype.isLastLine = function() {
      return this.lineNumber === this.lineCount - 1;
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
      this.lines = source.split('\n');
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
          return this.lintIncrement(token);
        case "THROW":
          return this.lintThrow(token);
        case "[":
        case "]":
          return this.lintArray(token);
        case "JS":
          return this.lintJavascript(token);
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

    LexicalLinter.prototype.lintJavascript = function(token) {
      return this.createLexError('no_backticks');
    };

    LexicalLinter.prototype.lintThrow = function(token) {
      var n1, n2, nextIsString, _ref;
      _ref = [this.peek(), this.peek(2)], n1 = _ref[0], n2 = _ref[1];
      nextIsString = n1[0] === 'STRING' || (n1[0] === '(' && n2[0] === 'STRING');
      if (nextIsString) return this.createLexError('no_throwing_strings');
    };

    LexicalLinter.prototype.lintIncrement = function(token) {
      var attrs;
      attrs = {
        context: "found '" + token[0] + "'"
      };
      return this.createLexError('no_plusplus', attrs);
    };

    LexicalLinter.prototype.lintIndentation = function(token) {
      var context, expected, ignoreIndent, isArrayIndent, isInterpIndent, isMultiline, lineNumber, numIndents, previous, previousIndentation, previousLine, previousSymbol, type, _ref;
      type = token[0], numIndents = token[1], lineNumber = token[2];
      if (token.generated != null) return null;
      previous = this.peek(-2);
      isInterpIndent = previous && previous[0] === '+';
      previous = this.peek(-1);
      isArrayIndent = this.inArray() && (previous != null ? previous.newLine : void 0);
      previousSymbol = (_ref = this.peek(-1)) != null ? _ref[0] : void 0;
      isMultiline = previousSymbol === '=' || previousSymbol === ',';
      ignoreIndent = isInterpIndent || isArrayIndent || isMultiline;
      if (this.isChainedCall()) {
        previousLine = this.lines[this.lineNumber - 1];
        previousIndentation = previousLine.match(/^(\s*)/)[1].length;
        numIndents -= previousIndentation;
      }
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
      var attrs, className, offset, _ref, _ref2, _ref3;
      if ((token.newLine != null) || ((_ref = this.peek()[0]) === 'INDENT' || _ref === 'EXTENDS')) {
        return null;
      }
      className = null;
      offset = 1;
      while (!className) {
        if (((_ref2 = this.peek(offset + 1)) != null ? _ref2[0] : void 0) === '.') {
          offset += 2;
        } else if (((_ref3 = this.peek(offset)) != null ? _ref3[0] : void 0) === '@') {
          offset += 1;
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
      if (attrs == null) attrs = {};
      attrs.lineNumber = this.lineNumber + 1;
      attrs.level = this.config[rule].level;
      return createError(rule, attrs);
    };

    LexicalLinter.prototype.peek = function(n) {
      if (n == null) n = 1;
      return this.tokens[this.i + n] || null;
    };

    LexicalLinter.prototype.inArray = function() {
      return this.arrayTokens.length > 0;
    };

    LexicalLinter.prototype.isChainedCall = function() {
      var i, lastNewLineIndex, lines, t, token, tokens;
      lines = (function() {
        var _len, _ref, _results;
        _ref = this.tokens.slice(0, this.i + 1 || 9e9);
        _results = [];
        for (i = 0, _len = _ref.length; i < _len; i++) {
          token = _ref[i];
          if (token.newLine != null) _results.push(i);
        }
        return _results;
      }).call(this);
      lastNewLineIndex = lines ? lines[lines.length - 2] : null;
      if (!(lastNewLineIndex != null)) return false;
      tokens = [this.tokens[lastNewLineIndex], this.tokens[lastNewLineIndex + 1]];
      return !!((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = tokens.length; _i < _len; _i++) {
          t = tokens[_i];
          if (t && t[0] === '.') _results.push(t);
        }
        return _results;
      })()).length;
    };

    return LexicalLinter;

  })();

  ASTLinter = (function() {

    function ASTLinter(source, config) {
      this.source = source;
      this.config = config;
      this.node = CoffeeScript.nodes(source);
      this.errors = [];
    }

    ASTLinter.prototype.lint = function() {
      this.lintNode(this.node);
      return this.errors;
    };

    ASTLinter.prototype.lintNode = function(node) {
      var attrs, complexity, error, name, rule, _ref,
        _this = this;
      name = node.constructor.name;
      complexity = name === 'If' || name === 'While' || name === 'For' || name === 'Try' ? 1 : name === 'Op' && ((_ref = node.operator) === '&&' || _ref === '||') ? 1 : name === 'Switch' ? node.cases.length : 0;
      node.eachChild(function(childNode) {
        if (!childNode) return false;
        complexity += _this.lintNode(childNode);
        return true;
      });
      rule = this.config.cyclomatic_complexity;
      if (name === 'Code' && complexity >= rule.value) {
        attrs = {
          context: complexity + 1,
          level: rule.level,
          line: 0
        };
        error = createError('cyclomatic_complexity', attrs);
        if (error) this.errors.push(error);
      }
      return complexity;
    };

    return ASTLinter;

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
    var astErrors, config, errors, lexErrors, lexicalLinter, lineErrors, lineLinter, tokensByLine;
    if (userConfig == null) userConfig = {};
    config = mergeDefaultConfig(userConfig);
    lexicalLinter = new LexicalLinter(source, config);
    lexErrors = lexicalLinter.lint();
    tokensByLine = lexicalLinter.tokensByLine;
    lineLinter = new LineLinter(source, config, tokensByLine);
    lineErrors = lineLinter.lint();
    astErrors = new ASTLinter(source, config).lint();
    errors = lexErrors.concat(lineErrors, astErrors);
    errors.sort(function(a, b) {
      return a.lineNumber - b.lineNumber;
    });
    return errors;
  };

}).call(this);
