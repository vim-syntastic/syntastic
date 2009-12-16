"============================================================================
"File:        html.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists("loaded_html_syntax_checker")
    finish
endif
let loaded_html_syntax_checker = 1

"bail if the user doesnt have tidy or grep installed
if !executable("tidy") || !executable("grep")
    finish
endif

function! SyntaxCheckers_html_GetLocList()

    "grep out the '<table> lacks "summary" attribute' since it is almost
    "always present and almost always useless
    let makeprg="tidy -e % 2>&1 \\| grep -v '\<table\> lacks \"summary\" attribute'"
    let errorformat='%Wline %l column %c - Warning: %m,%Eline %l column %c - Error: %m,%-G%.%#,%-G%.%#'
    let loclist = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

    "the file name isnt in the output so stick in the buf num manually
    for i in loclist
        let i['bufnr'] = bufnr("")
    endfor

    return loclist
endfunction
