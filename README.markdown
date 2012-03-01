                   ,
                  / \,,_  .'|
               ,{{| /}}}}/_.'            _____________________________________________
              }}}}` '{{'  '.            /                                             \
            {{{{{    _   ;, \          /                Gentlemen,                     \
         ,}}}}}}    /o`\  ` ;)        |                                                |
        {{{{{{   /           (        |                 this is ...                    |
        }}}}}}   |            \       |                                                |
       {{{{{{{{   \            \      |                                                |
       }}}}}}}}}   '.__      _  |     |    _____             __             __  _      |
       {{{{{{{{       /`._  (_\ /     |   / ___/__  ______  / /_____ ______/ /_(_)____ |
        }}}}}}'      |    //___/   --=:   \__ \/ / / / __ \/ __/ __ `/ ___/ __/ / ___/ |
    jgs `{{{{`       |     '--'       |  ___/ / /_/ / / / / /_/ /_/ (__  ) /_/ / /__   |
         }}}`                         | /____/\__, /_/ /_/\__/\__,_/____/\__/_/\___/   |
                                      |      /____/                                    |
                                      |                                               /
                                       \_____________________________________________/




Syntastic is a syntax checking plugin that runs files through external syntax
checkers and displays any resulting errors to the user. This can be done on
demand, or automatically as files are saved. If syntax errors are detected, the
user is notified and is happy because they didn't have to compile their code or
execute their script to find them.

At the time of this writing, syntax checking plugins exist for applescript, c,
coffee, cpp, css, cucumber, cuda, docbk, erlang, eruby, fortran,
gentoo_metadata, go, haml, haskell, html, javascript, json, less, lua, matlab,
perl, php, puppet, python, rst, ruby, sass/scss, sh, tcl, tex, vala, xhtml,
xml, xslt, yaml, zpt

Screenshot
----------

Below is a screenshot showing the methods that Syntastic uses to display syntax
errors.  Note that, in practise, you will only have a subset of these methods
enabled.

![Screenshot 1](https://github.com/scrooloose/syntastic/raw/master/_assets/screenshot_1.png)

1. Errors are loaded into the location list for the corresponding window.
2. When the cursor is on a line containing an error, the error message is echoed in the command window.
3. Signs are placed beside lines with errors - note that warnings are displayed in a different color.
4. There is a configurable statusline flag you can include in your statusline config.
5. Hover the mouse over a line containing an error and the error message is displayed as a balloon.
6. (not shown) Highlighting errors with syntax highlighting. Erroneous parts of lines can be highlighted.

Installation
------------

[pathogen.vim](https://github.com/tpope/vim-pathogen) is the recommended way to install syntastic.

    cd ~/.vim/bundle
    git clone https://github.com/scrooloose/syntastic.git

Then reload vim, run `:Helptags`, and check out `:help syntastic.txt`.


Google group
------------

To get information or make suggestions check out the [google group](https://groups.google.com/group/vim-syntastic).


FAQ
---

__Q. I installed syntastic but it isn't reporting any errors ...__

A. The most likely reason is that the syntax checker that it requires isn't installed. For example: python requires either `flake8`, `pyflakes` or `pylint` to be installed and in `$PATH`. To see which executable is required, just look in `syntax_checkers/<filetype>.vim`.

Another reason it could fail is that the error output for the syntax checker may have changed. In this case, make sure you have the latest version of the syntax checker installed. If it still fails then create an issue - or better yet, create a pull request.


Changelog
---------
2.3.0 (16-feb-2012)

  * Add syntastic_loc_list_height option
  * Allow errors to have a "subtype" that is signed differently to standard
    errors. Currently geared towards differentiating style errors from
    syntax errors. Currently implemented for phpcs (technosophos).
  * New checkers for:
    * yaml
    * haxe (davidB)
    * ocaml (edwintorok)
    * pylint (parantapa)
    * rust (cjab)
  * Updates to existing checkers:
    * jslint
    * jshint (gillesruppert)
    * fortran (bmattern)
    * sass
    * html (darcyparker)
    * coffee (darcyparker)
    * docbk (darcyparker)
    * xml
    * xslt
    * less (irrationalfab)
    * php (AD7six, technosophos)
    * cuda
    * python (mitchellh, pneff)
    * perl (Anthony Carapetis)
    * c (naoina, zsprackett)
    * puppet (frimik)

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
