"============================================================================
"File:        lslint.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Sam Wilson <tecywiz121 at hotmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists("g:loaded_syntastic_lsl_lslint_checker")
    finish
endif
let g:loaded_syntastic_lsl_lslint_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_lsl_lslint_GetLocList() dict
    let makeprg = self.makeprgBuild({
        \ 'exe': 'lslint',
        \ 'args': '-p' })

    let errorformat = '%-GTOTAL::%.%#,' .
        \ '%-G,' .
        \ '%E%f::ERROR:: ( %#%l\, %#%c): %m,' .
        \ '%W%f::WARNING:: ( %#%l\, %#%c): %m'

    return SyntasticMake({
        \   'makeprg': makeprg,
        \   'errorformat': errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \   'filetype': 'lsl',
    \   'name': 'lslint' })

let &cpo = s:save_cpo
unlet s:save_cpo
