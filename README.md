CoffeeLint
==========

CoffeeLint is a linter for CoffeeScript in it's infancy.

Usage
-----

To lint your scripts, run:

  > coffeelint app.coffee
  Lint free!

You can specify custom configuration as well:

   > coffeelint -f config.json app.coffee
   Lint free!

Get help.

   > coffeelint -h


Configuration
-------------

Every check in Coffeescript is configurable via a JSON file. Here is an example configuration:

    {
        trailing: false,    // Forbid trailing whitespace.
        tabs: false,        // Forbid tabs in indentation.
        lineLength: 80      // Forbid lines longer than 80 characters.
    }

Installation
------------

- Install node & npm.
- Run `npm install -g coffeelint`

