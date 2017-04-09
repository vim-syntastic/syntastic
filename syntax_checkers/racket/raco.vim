"============================================================================
"File:        raco.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Nymphium
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"============================================================================

if exists('g:loaded_syntastic_racket_raco_checker')
    finish
endif
let g:loaded_syntastic_racket_raco_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_racket_raco_GetHighlightRegex(item)
    if matchstr(a:item['text'], '\<type mismatch\>') !=# ''
        return '\V' . matchstr(a:item['text'], 'in: \zs.\+$')
    endif

    return ''
endfunction

function! SyntaxCheckers_racket_raco_GetLocList() dict
    let makeprg = self.makeprgBuild({'args_before': 'expand'})

    let errorformat =
        \ '%E%f:%l:%v: Type Checker: %m,%+C  expected:%m,%+C  given:%m,%Z %m,' .
        \ '%E%f:%l:%v: %m,' .
        \ '%-G%.%#'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'racket',
    \ 'name': 'raco' })

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
