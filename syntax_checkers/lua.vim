"============================================================================
"File:        lua.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Gregor Uhlenheuer <kongo2002 at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists('loaded_lua_syntax_checker')
    finish
endif
let loaded_lua_syntax_checker = 1

" check if the lua compiler is installed
if !executable('luac')
    finish
endif

function! SyntaxCheckers_lua_GetLocList()
    let makeprg = 'luac -p ' . shellescape(expand('%'))
    let errorformat =  'luac: %#%f:%l: %m'

    let loclist = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

    let bn = bufnr('')
    for loc in loclist
        let loc['bufnr'] = bn
        let loc['type'] = 'E'
    endfor

    return loclist
endfunction

