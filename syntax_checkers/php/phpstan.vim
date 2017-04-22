"============================================================================
"File:        phpstan.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Przepompownia przepompownia@users.noreply.github.com
"
"============================================================================

if exists('g:loaded_syntastic_php_phpstan_checker')
    finish
endif
let g:loaded_syntastic_php_phpstan_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_php_phpstan_GetLocList() dict
    let makeprg = self.makeprgBuild({
        \ 'args': 'analyse',
        \ 'post_args': '--level=5 --errorFormat raw' })

    let errorformat = '%f:%l:%m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'subtype' : 'Style' })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'php',
    \ 'name': 'phpstan'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
