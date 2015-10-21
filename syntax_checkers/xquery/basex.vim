"============================================================================
"File:        basex.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  James Wright <james dot jw at hotmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"
"============================================================================

if exists('g:loaded_syntastic_xquery_basex_checker')
    finish
endif
let g:loaded_syntastic_xquery_basex_checker = 1

let s:save_cpo = &cpo
set cpo&vim

if exists('g:syntastic_extra_filetypes')
    call add(g:syntastic_extra_filetypes, 'xquery')
else
    let g:syntastic_extra_filetypes = ['xquery']
endif

function SyntaxCheckers_xquery_basex_IsAvailable() dict
    return executable(expand(self.getExec(), 1))
endfunction

function SyntaxCheckers_xquery_basex_GetLocList() dict
    let makeprg = 'basex -z -q "inspect:module(' . "'" . expand("%:p") . "')" . '"'
    let errorformat =
        \ '%-GStopped at .\, %l/%c:,'.
        \ '%E[%.%#] Stopped at %f\, %l/%c:,'.
        \ '%Z[%t%#%n] %m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat
        \ })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'xquery',
    \ 'name': 'basex'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
