"============================================================================
"File:        jsxcs.vim
"Description: Javascript syntax checker - using jscs
"Maintainer:  Joe Lencioni <joe.lencioni@gmail.com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"============================================================================

if exists("g:loaded_syntastic_javascript_jsxcs_checker")
    finish
endif
let g:loaded_syntastic_javascript_jsxcs_checker = 1

if !exists('g:syntastic_javascript_jsxcs_sort')
    let g:syntastic_javascript_jsxcs_sort = 1
endif

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_javascript_jsxcs_GetLocList() dict
    let makeprg = self.makeprgBuild({ 'args_after': '--no-colors --reporter checkstyle' })

    let errorformat = '%f:%t:%l:%c:%m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'subtype': 'Style',
        \ 'preprocess': 'checkstyle',
        \ 'returns': [0, 2] })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'javascript',
    \ 'name': 'jsxcs'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sts=4 sw=4:
