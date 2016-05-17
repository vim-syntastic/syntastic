"============================================================================
"File:        clm.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Camil Staps <info at camilstaps dot nl>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists('g:loaded_syntastic_clean_clm_checker')
    finish
endif
let g:loaded_syntastic_clean_clm_checker = 1

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:syntastic_clean_cocl_errorformat')
    execute 'source ' . fnameescape(expand('<sfile>:p:h') . '/cocl_errorformat.vim')
endif

function! SyntaxCheckers_clean_clm_GetLocList() dict
    let module = expand('%:r', 1)

    let makeprg = self.makeprgBuild({
                \ 'args': '-c',
                \ 'fname': module })

    return SyntasticMake({
                \ 'cwd': expand('%:p:h', 1),
                \ 'makeprg': makeprg,
                \ 'errorformat': g:syntastic_clean_cocl_errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'clean',
    \ 'name': 'clm' })

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
