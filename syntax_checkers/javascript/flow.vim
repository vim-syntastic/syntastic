"============================================================================
"File:        flow.vim
"Description: Javascript syntax checker - using flow
"Maintainer:  Michael Robinson <mike@pagesofinterest.net>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"============================================================================

if exists('g:loaded_syntastic_javascript_flow_checker')
    finish
endif
let g:loaded_syntastic_javascript_flow_checker = 1

if !exists('g:syntastic_javascript_flow_sort')
    let g:syntastic_javascript_flow_sort = 1
endif

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_javascript_flow_IsAvailable() dict
    if !executable(self.getExec())
        return 0
    endif

    return executable(self.getExec())
endfunction

function! SyntaxCheckers_javascript_flow_GetLocList() dict
    let makeprg = self.makeprgBuild({
        \ 'args': '' })

    let errorformat =
                \ '%E,' .
                \ '%C%f:%l:%v\,%c: %m,' .
                \ '%C%\w%\\+%m,' .
                \ '%Z%\s%m,' .
                \ '%Z%m'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'javascript',
    \ 'name': 'flow'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sts=4 sw=4:
