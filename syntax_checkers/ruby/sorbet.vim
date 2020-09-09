"============================================================================
"File:        sorbet.vim
"Description: Syntax checking plugin for syntastic
"Maintainer:  Tom Morton <tomm@riseup.net>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists('g:loaded_syntastic_ruby_sorbet_checker')
    finish
endif
let g:loaded_syntastic_ruby_sorbet_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_ruby_sorbet_IsAvailable() dict
    if !executable(self.getExec())
        return 0
    endif
    return syntastic#util#versionIsAtLeast(self.getVersion(), [0, 1, 0])
endfunction

function! SyntaxCheckers_ruby_sorbet_GetLocList() dict
    let makeprg = self.makeprgBuild({ 'args_before': 'tc' })

    let errorformat = '%f:%l: %m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'type': 'E',
        \ 'subtype': 'Style' })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'ruby',
    \ 'name': 'sorbet',
    \ 'exec': 'srb' })

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
