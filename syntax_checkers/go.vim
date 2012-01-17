"============================================================================
"File:        go.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
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

let s:supported_checkers = ["gofmt", "6g"]

function! s:load_checker(checker)
    exec "runtime syntax_checkers/go/" . a:checker . ".vim"
endfunction

if exists("g:syntastic_go_checker")
    if index(s:supported_checkers, g:syntastic_go_checker) != -1 && executable(g:syntastic_go_checker)
        call s:load_checker(g:syntastic_go_checker)
    else
        echoerr "GO syntax not supported or not installed."
    endif
else
    for checker in s:supported_checkers
        if executable(checker)
            call s:load_checker(checker)
            break
        endif
    endfor
endif
