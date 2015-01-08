"============================================================================
"File:        phpcs.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists("g:loaded_syntastic_php_phpcs_checker")
    finish
endif
let g:loaded_syntastic_php_phpcs_checker = 1

if !exists('g:syntastic_php_phpcs_tab_width')
    let g:syntastic_php_phpcs_tab_width = 4
endif

if !exists('g:syntastic_php_phpcs_column_specifier')
    let g:syntastic_php_phpcs_column_specifier = '%c'
endif

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_php_phpcs_GetLocList() dict
    if g:syntastic_php_phpcs_tab_width
        let args = '--tab-width=' . g:syntastic_php_phpcs_tab_width
    else
        let args = ''
    endif

    let makeprg = self.makeprgBuild({
        \ 'args_after': '--report=csv',
        \ 'args': args })

    let errorformat =
        \ '%-GFile\,Line\,Column\,Type\,Message\,Source\,Severity%.%#,'.
        \ '"%f"\,%l\,' . g:syntastic_php_phpcs_column_specifier . '\,%t%*[a-zA-Z]\,"%m"\,%*[a-zA-Z0-9_.-]\,%*[0-9]%.%#'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'subtype': 'Style' })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'php',
    \ 'name': 'phpcs' })

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
