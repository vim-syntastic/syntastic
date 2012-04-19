"============================================================================
"File:        gofmt.vim
"Description: Check go syntax using gofmt
"Maintainer:  Brandon Thomson <bt@brandonthomson.com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
function! SyntaxCheckers_go_GetLocList()
    let makeprg = 'gofmt %'
    let errorformat = '%f:%l:%c: %m,%-G%.%#'
    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat, 'defaults': {'type': 'e'} })
endfunction
