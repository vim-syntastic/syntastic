"============================================================================
"File:        alex.vim
"Description: Insensitive, inconsiderate writing checking plugin for 
"             syntastic.vim using `alex` (https://github.com/wooorm/alex).
"Maintainer:  Tim Carry <tim at pixelastic dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists('g:loaded_syntastic_markdown_alex_checker')
    finish
endif
let g:loaded_syntastic_markdown_alex_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_markdown_alex_GetLocList() dict
    " printm "test"
    let makeprg = self.makeprgBuild({})

    let errorformat = '%t:%l:%m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'defaults': {'bufnr': bufnr('')},
        \ 'subtype': 'Style',
        \ 'preprocess': 'alex'})
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'markdown',
    \ 'name': 'alex'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:


