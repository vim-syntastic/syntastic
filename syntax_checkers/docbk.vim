"============================================================================
"File:        docbk.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists("loaded_docbk_syntax_checker")
    finish
endif
let loaded_docbk_syntax_checker = 1

"bail if the user doesnt have tidy or grep installed
if !executable("xmllint")
    finish
endif

function! SyntaxCheckers_docbk_GetLocList()

    let makeprg="xmllint --xinclude --noout --postvalid ".shellescape(expand(%:p))
    let errorformat='%E%f:%l: parser error : %m,%W%f:%l: parser warning : %m,%E%f:%l:%.%# validity error : %m,%W%f:%l:%.%# validity warning : %m,%-Z%p^,%-C%.%#,%-G%.%#'
    let loclist = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

    return loclist
endfunction
