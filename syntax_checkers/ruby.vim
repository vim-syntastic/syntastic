"============================================================================
"File:        ruby.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"Supports MRI and JRuby but loads the MRI syntax checker by default.
"
"Use the g:syntastic_ruby_checker option to specify which checker to load -
"set it to "jruby" to load the jruby checker.
"============================================================================
if exists("loaded_ruby_syntax_checker")
    finish
endif
let loaded_ruby_syntax_checker = 1

if !exists("g:syntastic_ruby_checker")
    let g:syntastic_ruby_checker = "mri"
endif
exec "runtime! syntax_checkers/ruby/" . g:syntastic_ruby_checker . ".vim"

