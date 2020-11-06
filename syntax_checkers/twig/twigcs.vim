"============================================================================
"File:        twigcs.vim
"Description: Syntax checking plugin for syntastic
"Maintainer:  Ciloe <escrichjimmy at yahoo dot fr>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists('g:loaded_syntastic_twig_twigcs_checker')
    finish
endif
let g:loaded_syntastic_twig_twigcs_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_twig_twigcs_GetLocList() dict
    let makeprg = self.makeprgBuild({ 'args_after': '--reporter=emacs' })

    let errorformat =
        \ '%f:%l:%c: %trror - %m,' .
        \ '%f:%l:%c: %tarning - %m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'subtype': 'Style' })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'twig',
    \ 'name': 'twigcs' })

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
