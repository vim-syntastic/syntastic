"============================================================================
"File:        sass.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists("loaded_sass_syntax_checker")
    finish
endif
let loaded_sass_syntax_checker = 1

"bail if the user doesnt have the sass binary installed
if !executable("sass")
    finish
endif

"By default do not check partials as unknown variables are a syntax error
if !exists("g:syntastic_sass_check_partials")
    let g:syntastic_sass_check_partials = 0
endif

"use compass imports if available
let s:imports = ""
if executable("compass")
    let s:imports = "--compass"
endif

function! SyntaxCheckers_sass_GetLocList()
    if !g:syntastic_sass_check_partials && expand('%:t')[0] == '_'
        return []
    end
    let makeprg='sass --no-cache '.s:imports.' --check '.shellescape(expand('%'))
    let errorformat = '%ESyntax %trror:%m,%C        on line %l of %f,%Z%.%#'
    let errorformat .= ',%Wwarning on line %l:,%Z%m,Syntax %trror on line %l: %m'
    let loclist = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

    return loclist
endfunction
