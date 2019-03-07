"============================================================================
"File:        hlint.vim
"Description: Syntax checking plugin for syntastic
"Maintainer:  Nicolas Wu <nicolas.wu at gmail dot com>
"License:     BSD
"============================================================================

if exists('g:loaded_syntastic_haskell_hlint_checker')
    finish
endif
let g:loaded_syntastic_haskell_hlint_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_haskell_hlint_IsAvailable() dict
    if !executable(self.getExec())
        return 0
    endif
    return syntastic#util#versionIsAtLeast(self.getVersion(), [1, 9, 4])
endfunction

function! SyntaxCheckers_haskell_hlint_GetLocList() dict
    let buf = bufnr('')
    let makeprg = self.makeprgBuild({
        \ 'args_before': '--color=never',
        \ 'fname': syntastic#util#shescape(fnamemodify(bufname(buf), ':p')) })

    let errorformat =
        \ '%E%f:%l:%v: Error while reading hint file\, %m,' .
        \ '%E%f:%l:%v: Error: %m,' .
        \ '%W%f:%l:%v: Warning: %m,' .
        \ '%W%f:%l:%v: Suggestion: %m,' .
        \ '%C%m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'defaults': {'vcol': 1},
        \ 'postprocess': ['compressWhitespace'] })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'haskell',
    \ 'name': 'hlint'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
