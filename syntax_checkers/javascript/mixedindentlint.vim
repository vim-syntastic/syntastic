"============================================================================
"File:        mixedindentlint.vim
"Description: Mixed indentation linter for vim
"Maintainer:  Payton Swick <payton@foolord.com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"============================================================================

if exists('g:loaded_syntastic_javascript_mixedindentlint_checker')
    finish
endif
let g:loaded_syntastic_javascript_mixedindentlint_checker = 1

if !exists('g:syntastic_javascript_mixedindentlint_generic')
    let g:syntastic_javascript_mixedindentlint_generic = 0
endif

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_javascript_mixedindentlint_IsAvailable() dict
    if g:syntastic_javascript_mixedindentlint_generic
        call self.log('generic mixedindentlint, exec =', self.getExec())
    endif

    if !executable(self.getExec())
        return 0
    endif
    return g:syntastic_javascript_mixedindentlint_generic || syntastic#util#versionIsAtLeast(self.getVersion(), [1, 0, 0])
endfunction

function! SyntaxCheckers_javascript_mixedindentlint_GetLocList() dict
    let makeprg = self.makeprgBuild({})

    let errorformat = 'Line %l in "%f" %.%#.'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'defaults': { 'bufnr': bufnr(''), 'text': 'Indentation that differs from rest of file' } })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'javascript',
    \ 'name': 'mixedindentlint'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
