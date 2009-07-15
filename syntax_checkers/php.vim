"============================================================================
"File:        php.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin_grenfell at msn dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists("loaded_php_syntax_checker")
    finish
endif
let loaded_php_syntax_checker = 1

"bail if the user doesnt have php installed
if !executable("php") || !executable("tidy")
    finish
endif

function! SyntaxCheckers_php_GetLocList()
    return extend(s:PhpErrors(), s:HtmlErrors())
endfunction

function! s:PhpErrors()
    set makeprg=php\ -l\ %
    set errorformat=%-GNo\ syntax\ errors\ detected\ in%.%#,%-GErrors\ parsing\ %.%#,%-G\\s%#,%EParse\ error:\ syntax\ error\\,\ %m\ in\ %f\ on\ line\ %l,
    silent lmake!
    return getloclist(0)
endfunction

function! s:HtmlErrors()
    let &makeprg="tidy -e % 2>&1"

    set errorformat=%Wline\ %l\ column\ %c\ -\ Warning:\ %m,%Eline\ %l\ column\ %c\ -\ Error:\ %m,%-G%.%#,%-G%.%#
    silent lmake!

    let loclist = filter(getloclist(0), 'index(s:html_ignored_errors, v:val["text"]) == -1')

    "the file name isnt in the output so stick in the buf num manually
    for i in loclist
        let i['bufnr'] = bufnr("")
    endfor

    return loclist
endfunction

let s:html_ignored_errors = ["inserting missing 'title' element",
                           \ 'missing <!DOCTYPE> declaration',
                           \ 'inserting implicit <body>',
                           \ '<table> lacks "summary" attribute']
