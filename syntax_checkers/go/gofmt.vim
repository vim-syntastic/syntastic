"============================================================================
"File:        gofmt.vim
"Description: Check go syntax using 'gofmt -l'
"Maintainer:  Brandon Thomson <bt@brandonthomson.com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
" This syntax checker does not reformat your source code.
" Use a BufWritePre autocommand to that end:
"   autocmd FileType go autocmd BufWritePre <buffer> Fmt
"============================================================================
function! SyntaxCheckers_go_GetLocList()
    let makeprg = 'gofmt -l % 1>/dev/null'
    let errorformat = '%f:%l:%c: %m,%-G%.%#'
    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat, 'defaults': {'type': 'e'} })
endfunction
