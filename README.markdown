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
