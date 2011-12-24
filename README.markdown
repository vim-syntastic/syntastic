Syntastic
=========

Run for the sink and fetch a glass of water, and snatch your padded
bike shorts off the clothes horse on the way back cos syntastic is gonna kick
you in the ass hard enough to cause the oral ejection of your spleen.

Tired of waiting for your rails environment to load only to find you failed @ syntax??

SCREW THAT!

Did you just reload that web page only to be told you can't balance brackets to save your own testicles?

F#%K THAT!!

Have you just wasted precious seconds of your life only to see gcc whinging about a missing semi colon?

RAPING DAMN IT!!!1


Syntastic can save you time by running your code through external syntax
checkers to detect errors. It provides the following features:

* Errors can be loaded and displayed in a location list.
* A configurable statusline flag is available to display a summary of errors.
* Signs can be placed next to lines with errors or warnings.
* Offending parts of lines can be highlighted.
* Balloons are can be used to display error messages.

Syntastic can be configured to be as intrusive or as passive as you want it to
be - to the point where you invoke it manually.

At the time of this writing, syntax checking plugins exist for c, coffee, cpp,
css, cucumber, cuda, docbk, erlang, eruby, fortran, go, haml, haskell, html,
javascript, less, lua, matlab, perl, php, puppet, python, ruby, sass/scss, sh,
tcl, tex, vala, xhtml, xml, xslt, zpt.


Installation
------------

[pathogen.vim](https://github.com/tpope/vim-pathogen) is the recommended way to install syntastic.

    cd ~/.vim/bundle
    git clone https://github.com/scrooloose/syntastic.git

Then reload vim, run `:Helptags`, and check out `:help syntastic.txt`.


Google group
------------

To get information or make suggestions check out the [google group](https://groups.google.com/group/vim-syntastic).


Changelog
---------

2.2.0 (24-dec-2011)

  * only do syntax checks when files are saved (not when first opened) - add g:syntastic_check_on_open option to get the old behavior back
  * bug fix with echoing error messages; fixes incompatability with cmd-t (datanoise)
  * dont allow warnings to mask errors when signing/echoing errors (ashikase)
  * auto close location list when leaving buffer. (millermedeiros)
  * update errors appropriately when :SyntasticToggleMode is called
  * updates/fixes to existing checkers:
    * javascript/jshint (millermedeiros)
    * javascript/jslint
    * c (kongo2002)
  * Support for new filetypes:
    * JSON (millermedeiros, tocer)
    * rst (reStructuredText files) (JNRowe)
    * gentoo-metadata (JNRowe)

2.1.0 (14-dec-2011)

  * when the cursor is on a line containing an error, echo the
  * error msg (kevinw)
  * various bug fixes and refactoring
  * updates/fixes to existing checkers:
    * html (millermedeiros)
    * erlang
    * coffeescript
    * javascript
    * sh
    * php (add support for phpcs - technosophos)
  * add an applescript checker (Zhai Cai)
  * add support for hyphenated filetypes (JNRowe)

2.0.0 (2-dec-2011):

  * Add support for highlighting the erroneous parts of lines (kstep)
  * Add support for displaying errors via balloons (kstep)
  * Add syntastic_mode_map option to give more control over when checking should be done.
  * Add :SyntasticCheck command to force a syntax check -  useful in passive mode (justone).
  * Add the option to automatically close the location list, but not automatically open it (milkypostman)
  * Add syntastic_auto_jump option to automatically jump to the first error (milkypostman)
  * Only source syntax checkers as needed - instead of loading all of them when vim starts

  * Support for new filetypes:
    * less (julienXX)
    * docbook (tpope)
    * matlab (jasongraham)
    * go (dtjm)
    * puppet (uggedal, roman, zsprackett)
    * haskell (baldo, roman)
    * tcl (et)
    * vala (kstep)
    * cuda (temporaer)
    * css (oryband, sitedyno)
    * fortran (Karl Yngve Lervåg)
    * xml (kusnier)
    * xslt (kusnier)
    * erlang (kTT)
    * zpt (claytron)

  * updates to existing checkers:
    * javascript (mogren, bryanforbes, cjab, ajduncan)
    * sass/scss (tmm1, atourino, dlee, epeli)
    * ruby (changa)
    * perl (harleypig)
    * haml (bmihelac)
    * php (kstep, docteurklein)
    * python (kstep, soli)
    * lua (kstep)
    * html (kstep)
    * xhtml (kstep)
    * c (kongo2002, brandonw)
    * cpp (kongo2002)
    * coffee (industrial)
    * eruby (sergevm)
