"============================================================================
"File:        6g.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Sam Nguyen <samxnguyen@gmail.com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
function! SyntaxCheckers_go_GetLocList()
    let makeprg = '6g -o /dev/null %'
    let errorformat = '%E%f:%l: %m'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction
