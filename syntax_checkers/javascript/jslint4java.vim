"============================================================================
"File:        jslint4java.vim
"Description: Javascript syntax checker - using jslint4java
"Maintainer:  novaez
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"============================================================================

if exists("g:loaded_syntastic_javascript_jslint4java_checker")
    finish
endif
let g:loaded_syntastic_javascript_jslint4java_checker = 1

if !exists("g:syntastic_javascript_jslint4java_args")
    let g:syntastic_javascript_jslint4java_args = "--browser --indent 4 --nomen --plusplus --sloppy"
endif

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_javascript_jslint4java_GetLocList() dict
    let makeprg = self.makeprgBuild({
        \ 'exe_after': '-jar ' . g:syntastic_javascript_jslint4java_jarfile,
        \ 'args': g:syntastic_javascript_jslint4java_args })

    let errorformat = 'jslint:%f:%l:%c:%m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'javascript',
    \ 'exec': 'java',
    \ 'name': 'jslint4java'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sts=4 sw=4:
