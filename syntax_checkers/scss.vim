
"============================================================================
"File:        scss.vim
"Description: scss syntax checking plugin for syntastic
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists("loaded_scss_syntax_checker")
    finish
endif
let loaded_scss_syntax_checker = 1

"bail if the user doesnt have the sass binary installed
if !executable("sass")
    finish
endif

runtime syntax_checkers/sass.vim

function! SyntaxCheckers_scss_GetLocList()
    return SyntaxCheckers_sass_GetLocList()
endfunction
