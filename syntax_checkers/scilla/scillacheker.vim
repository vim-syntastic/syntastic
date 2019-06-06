"============================================================================
"File:        scillachecker.vim
"Description: Syntax checking plugin for syntastic
"Maintainer:  Bogdan Gusiev <agresso@gmail.com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"============================================================================

if exists('g:loaded_syntastic_scilla_scillachecker_checker')
    finish
endif
let g:loaded_syntastic_scilla_scillachecker_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_scilla_scillachecker_GetLocList() dict
    let makeprg = self.makeprgBuild({})

    let errorformat = '%f:%l:%c:%m'

    let loclist = SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat })

    return loclist
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'scilla',
    \ 'name': 'scillachecker',
    \ 'exec': 'scilla-checker'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:

