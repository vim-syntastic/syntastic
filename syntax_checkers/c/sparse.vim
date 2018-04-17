"============================================================================
"File:        sparse.vim
"Description: Syntax checking plugin for syntastic using sparse.pl
"Maintainer:  Daniel Walker <dwalker at fifo99 dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"============================================================================

if exists('g:loaded_syntastic_c_sparse_checker')
    finish
endif
let g:loaded_syntastic_c_sparse_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_c_sparse_GetLocList() dict
    let buf = bufnr('')

    let makeprg = self.makeprgBuild({
        \ 'args': syntastic#c#ReadConfig(syntastic#util#bufVar(buf, 'sparse_config_file')),
        \ 'args_after': '-ftabstop=' . &ts })

    let errorformat =
        \ '%f:%l:%v: %trror: %m,' .
        \ '%f:%l:%v: %tarning: %m,'

    let loclist = SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'defaults': {'bufnr': bufnr('')},
        \ 'returns': [0, 1] })
    return loclist
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'c',
    \ 'name': 'sparse'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
