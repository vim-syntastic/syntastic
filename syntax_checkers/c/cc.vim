"============================================================================
"File:        c.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Gregor Uhlenheuer <kongo2002 at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists('g:loaded_syntastic_c_cc_checker')
    finish
endif
let g:loaded_syntastic_c_cc_checker = 1

if !exists('g:syntastic_c_compiler_options')
    let g:syntastic_c_compiler_options = '-std=c99'
endif

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_c_cc_IsAvailable() dict
    if !exists('g:syntastic_c_compiler')
        let g:syntastic_c_compiler = self.getExec()
    endif
    call self.log('g:syntastic_c_compiler =', g:syntastic_c_compiler)
    return executable(expand(g:syntastic_c_compiler, 1))
endfunction

function! SyntaxCheckers_c_cc_GetLocList() dict
    return syntastic#c#GetLocList('c', 'cc', {
        \ 'errorformat':
        \     '%-G%f:%s:,' .
        \     '%-G%f:%l: %#error: %#(Each undeclared identifier is reported only%.%#,' .
        \     '%-G%f:%l: %#error: %#for each function it appears%.%#,' .
        \     '%-GIn file included%.%#,' .
        \     '%-G %#from %f:%l\,,' .
        \     '%f:%l:%c: %trror: %m,' .
        \     '%f:%l:%c: %tarning: %m,' .
        \     '%f:%l:%c: %m,' .
        \     '%f:%l: %trror: %m,' .
        \     '%f:%l: %tarning: %m,'.
        \     '%f:%l: %m',
        \ 'main_flags': '-x c -fsyntax-only',
        \ 'header_flags': '-x c',
        \ 'header_names': '\m\.h$' })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'c',
    \ 'name': 'cc' })

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
