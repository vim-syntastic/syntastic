"============================================================================
"File:        pyang.vim
"Description: Syntax checking plugin for syntastic.vim
"Authors:     joshua.downer@gmail.com
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

    let errorformat = '%f:%l:%m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'postprocess': ['filterForeignErrors'] })
endfunction

runtime! syntax_checkers/yang/pyang.vim

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'yang',
    \ 'name': 'pyang'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
