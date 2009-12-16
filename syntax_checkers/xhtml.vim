"============================================================================
"File:        xhtml.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists("loaded_xhtml_syntax_checker")
    finish
endif
let loaded_xhtml_syntax_checker = 1

"bail if the user doesnt have tidy or grep installed
if !executable("tidy")
    finish
endif

function! SyntaxCheckers_xhtml_GetLocList()

    let makeprg="tidy -xml -e %"
    let errorformat='%Wline %l column %c - Warning: %m,%Eline %l column %c - Error: %m,%-G%.%#,%-G%.%#'
    let loclist = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

    "the file name isnt in the output so stick in the buf num manually
    for i in loclist
        let i['bufnr'] = bufnr("")
    endfor

    return loclist
endfunction
