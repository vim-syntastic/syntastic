"============================================================================
"File:        pyang.vim
"Description: Syntax checking plugin for syntastic.vim
"Authors:     joshua.downer@gmail.com
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists('g:loaded_syntastic_yang_pyang_checker')
    finish
endif
let g:loaded_syntastic_yang_pyang_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_yang_pyang_GetLocList() dict
    let makeprg = self.makeprgBuild({})

    let errorformat =
        \ '%W%f:%l: warning: %m,' .
        \ '%E%f:%l: error: %m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'postprocess': ['filterForeignErrors'] })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'yang',
    \ 'name': 'pyang'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
