"============================================================================
"File:        go.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Sam Nguyen <samxnguyen@gmail.com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists("loaded_go_syntax_checker")
    finish
endif
let loaded_go_syntax_checker = 1

"bail if the user doesnt have 6g installed
if !executable("6g")
    finish
endif

function! SyntaxCheckers_go_GetLocList()
    let makeprg = '6g -o /dev/null %'
    let errorformat = '%E%f:%l: %m'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction
