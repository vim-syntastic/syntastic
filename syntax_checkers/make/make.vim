"============================================================================
"File:        make.vim
"Description: Syntax checking plugin for makefiles.
"Maintainer:  Steven Myint
"
"============================================================================

if exists("g:loaded_syntastic_make_make_checker")
    finish
endif
let g:loaded_syntastic_make_make_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_make_make_GetLocList() dict
    let makeprg = self.makeprgBuild({
        \ 'args': '--dry-run --file'})

    let errorformat = '%f:%l: %m'

    let loclist = SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'returns': [0, 2]})

    return loclist
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'make',
    \ 'name': 'make'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sts=4 sw=4:
