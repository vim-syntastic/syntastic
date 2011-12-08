CoffeeLint
==========

CoffeeLint is a linter for CoffeeScript. The library is in it's infancy, so it
only checks a few aspects of the code, and even then there are kinks. It's not
quite ready for primetime, but give it a whirl if you'd like. Feedback is more
than welcome.

Checks
------

CoffeeLint supports the following checks:

- Forbid trailing whitespace (default: enabled)
- Forbid indentation with tabs (default: enabled)
- Maximum line length (default: 80 characters)

Installation
------------

- Install node & npm.
- Run `npm install -g coffeelint`

Usage
-----

To lint your scripts, run:

    $ coffeelint app.coffee
    Lint free!

To specify custom configuration, run like so:

    $ coffeelint -f config.json app.coffee
    Lint free!

Get help.

    $ coffeelint -h


Configuration
-------------

Every check in Coffeescript is configurable via a JSON file. Here is some example configuration:

    {
        trailing: false,    // Forbid trailing whitespace.
        tabs: false,        // Forbid tabs in indentation.
        lineLength: 80      // Forbid lines longer than 80 characters.
    }

License
-------

See LICENSE for details.
