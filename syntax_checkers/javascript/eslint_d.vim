"============================================================================
"File:        eslint_d.vim
"Description: Javascript syntax checker - using eslint
"Maintainer:  Maximilian Antoni
"License:     MIT <https://github.com/mantoni/eslint_d.js/blob/master/LICENSE>
"============================================================================

if exists('g:loaded_syntastic_javascript_eslint_d_checker')
    finish
endif
let g:loaded_syntastic_javascript_eslint_d_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_javascript_eslint_d_IsAvailable() dict
    if executable(self.getExec())
        return 1
    endif
    return 0
endfunction

function! SyntaxCheckers_javascript_eslint_d_GetLocList() dict
    let makeprg = self.makeprgBuild({'fname_before': '--format compact'})

    let errorformat =
        \ '%E%f: line %l\, col %c\, Error - %m,' .
        \ '%W%f: line %l\, col %c\, Warning - %m'

    let loclist = SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat})

    return loclist
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'javascript',
    \ 'name': 'eslint_d'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
