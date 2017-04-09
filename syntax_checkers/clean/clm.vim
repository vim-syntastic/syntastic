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

function! SyntaxCheckers_clean_clm_IsAvailable() dict
    return syntastic#util#versionIsAtLeast(self.getVersion(), [2,4])
endfunction

function! SyntaxCheckers_clean_clm_GetLocList() dict
    let module = expand('%:t:r', 1)
    let moddir = expand('%:p:h', 1)

    let makeprg = self.makeprgBuild({
                \ 'args_before': '-c',
                \ 'fname': syntastic#util#shescape(module) })

    " (Mainly) from timjs/clean-vim
    let errorformat  = '%E%trror [%f\,%l]: %m' " General error (without location info)
    let errorformat .= ',%E%trror [%f\,%l\,]: %m' " General error (without location info)
    let errorformat .= ',%E%trror [%f\,%l\,%s]: %m' " General error
    let errorformat .= ',%E%type error [%f\,%l\,%s]:%m' " Type error
    let errorformat .= ',%E%tverloading error [%f\,%l\,%s]:%m' " Overloading error
    let errorformat .= ',%E%tniqueness error [%f\,%l\,%s]:%m' " Uniqueness error
    let errorformat .= ',%E%tarse error [%f\,%l;%c\,%s]: %m' " Parse error
    let errorformat .= ',%+C %m' " Extra info
    let errorformat .= ',%-G%s' " Ignore rest

    return SyntasticMake({
                \ 'cwd': moddir,
                \ 'makeprg': makeprg,
                \ 'errorformat': errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'clean',
    \ 'name': 'clm' })

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
