"============================================================================
"File:        yard.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Steve Loveless
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists('g:loaded_syntastic_ruby_yard_checker')
    finish
endif
let g:loaded_syntastic_ruby_yard_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_ruby_yard_IsAvailable() dict
    if !executable(self.getExec())
        return 0
    endif
    return syntastic#util#versionIsAtLeast(self.getVersion(), [0, 7, 0])
endfunction

function! SyntaxCheckers_ruby_yard_GetLocList() dict
    let makeprg = self.makeprgBuild({ 'args': 'stats' })

    " Lines that contain the error info
    let errorformat = '%W[warn]: %m,%Z    in file `%f'' near line %l,'
    let errorformat .= '%E[error]: %m,%Z    in file `%f'' near line %l'

    let loclist = SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat})

    return loclist
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'ruby',
    \ 'name': 'yard'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
