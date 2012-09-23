"============================================================================
"File:        slim.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists("loaded_slim_syntax_checker")
    finish
endif
let loaded_slim_syntax_checker = 1

"bail if the user doesnt have the slim binary installed
if !executable("slimrb")
    finish
endif

function! s:SlimrbVersion()
    if !exists('s:slimrb_version')
        let output = system("slimrb --version 2>/dev/null")
        let output = substitute(output, '\n$', '', '')
        let output = substitute(output, '^slim ', '', 'i')
        let s:slimrb_version = split(output, '\.')
    end
    return s:slimrb_version
endfunction

function! SyntaxCheckers_slim_GetLocList()
    let makeprg = "slimrb -c " . shellescape(expand("%"))
    if SyntasticIsVersionAtLeast(s:SlimrbVersion(), [1,3,1])
        let errorformat = '%C\ %#%f\, Line %l\, Column %c,%-G\ %.%#,%ESlim::Parser::SyntaxError: %m,%+C%.%#'
    else
        let errorformat = '%C\ %#%f\, Line %l,%-G\ %.%#,%ESlim::Parser::SyntaxError: %m,%+C%.%#'
    endif
    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction
