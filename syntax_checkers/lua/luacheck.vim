"============================================================================
"File:        luacheck.vim
"Description: Lua static analysis using luacheck
"Maintainer:  Thiago Bastos <tbastos@tbastos.com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"============================================================================

if exists("g:loaded_syntastic_lua_luacheck_checker")
    finish
endif
let g:loaded_syntastic_lua_luacheck_checker = 1

if !exists('g:syntastic_lua_luacheck_sort')
    let g:syntastic_lua_luacheck_sort = 1
endif

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_lua_luacheck_GetHighlightRegex(item)
    let term = matchstr(a:item['text'], '''\zs.*\ze''') " matches the substring wrapped in single quotes
    if term != ''
        let term = '\V\<' . escape(term, '\') . '\>'
    endif
    return term
endfunction

function! SyntaxCheckers_lua_luacheck_GetLocList() dict
    let makeprg = self.makeprgBuild({ 'args_after': '--no-color' })

    let errorformat =
        \ '%f:%l:%c: %m,'.
        \ '%-G%.%#'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
            \ 'filetype': 'lua',
            \ 'name': 'luacheck' })

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sts=4 sw=4:
