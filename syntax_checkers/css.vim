"============================================================================
"File:        css.vim
"Description: Syntax checking plugin for syntastic.vim using `csslint` CLI tool (http://csslint.net).
"Maintainer:  Ory Band <oryband at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"============================================================================
if exists("loaded_css_syntax_checker")
    finish
endif
let loaded_css_syntax_checker = 1

" Bail if the user doesn't have `csslint` installed.
if !executable("csslint")
    finish
endif

function! SyntaxCheckers_css_GetLocList()
    let makeprg = 'csslint '.shellescape(expand('%'))

    " Print CSS Lint's 'Welcome' and error/warning messages. Ignores the code line.
    let errorformat = '%+Gcsslint:\ There%.%#,%A%f:,%C%n:\ %t%\\w%\\+\ at\ line\ %l\,\ col\ %c,%Z%m\ at\ line%.%#,%A%>%f:,%C%n:\ %t%\\w%\\+\ at\ line\ %l\,\ col\ %c,%Z%m,%-G%.%#'

    let loclist = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

    for i in loclist
        let i['bufnr'] = bufnr("")
    endfor

    return loclist
endfunction
