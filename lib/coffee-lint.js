(function() {
  /*
  CoffeeLint
  
  Copyright (c) 2011 Matthew Perpick
  */
  var coffeelint, fs, path;
  fs = require('fs');
  path = require('path');
  coffeelint = exports;
  coffeelint.VERSION = (function() {
    var package;
    package = path.join(__dirname, '..', 'package.json');
    return JSON.parse(fs.readFileSync(package)).version;
  })();
}).call(this);
