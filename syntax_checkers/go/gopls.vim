"============================================================================
"File:        gopls.vim
"Description: Check go syntax using 'gopls check'
"Maintainer:  Jean-Philippe Guérard <jean dash philippe dot guerard at tigreraye dot org>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"============================================================================

if exists('g:loaded_syntastic_go_gopls_checker')
    finish
endif
let g:loaded_syntastic_go_gopls_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_go_gopls_IsAvailable() dict
    if !executable(self.getExec())
        return 0
    endif
    " Older version of gopls only understand 'gopls serve', but not 'gopls
    " version' or 'gopls check'
    call syntastic#util#system(self.getExecEscaped() . ' version')
    return v:shell_error == 0
endfunction

function! SyntaxCheckers_go_gopls_GetLocList() dict
    let makeprg = self.makeprgBuild({ 'args_before':  'check' })

    let errorformat =
        \ '%f:%l:%c: %m,' .
        \ '%f:%l:%c-%\\d%\\+: %m,' .
        \ '%-G%.%#'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'defaults': {'type': 'e'},
        \ 'subtype': 'Style' })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'go',
    \ 'name': 'gopls',
    \ 'exec': 'gopls' })

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
