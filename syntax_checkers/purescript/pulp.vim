"============================================================================
"File:        pulp.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Sean Hess <seanhess at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists('g:loaded_syntastic_purescript_pulp_checker')
    finish
endif
let g:loaded_syntastic_purescript_pulp_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_purescript_pulp_GetLocList() dict

    let makeprg = self.makeprgBuild({
        \ 'exe_after': 'build --main ',
        \ 'fname': syntastic#util#shexpand('%:p') })

    let errorformat =
        \ '%E\\s%#psc: %m,' .
        \ '%C\\s%#at \"%f\" \(line %l\, column %c\)%.%#,' .
        \ '%E\\s%#\"%f\" \(line %l\, column %c\)%.%#,' .
        \ '%E%.%#Error at %f line %l\, column %c - %.%#,'.
        \ '%-G\* ERROR: Subcommand%.%#,' .
        \ '\* ERROR: %m,' .
        \ '%Z\\s%#See http%.%#,' .
        \ '%C\\s%#%m,' .
        \ '%Z'


    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat })

endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'purescript',
    \ 'name': 'pulp'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
