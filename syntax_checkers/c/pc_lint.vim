"============================================================================
"File:        pc_lint.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Steve Bragg <steve at empresseffects dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists("g:loaded_syntastic_c_pc_lint_checker")
    finish
endif
let g:loaded_syntastic_c_pc_lint_checker = 1

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:syntastic_pc_lint_config_file')
    let g:syntastic_pc_lint_config_file = 'options.lnt'
endif

function! SyntaxCheckers_c_pc_lint_GetLocList() dict
    let config = findfile(g:syntastic_pc_lint_config_file, '.;')

    " -hF1          - show filename, try to make message 1 line
    " -width(0,0)   - make sure there are no line breaks
    let makeprg = self.makeprgBuild({
        \ 'args': (filereadable(config) ? syntastic#util#shescape(fnamemodify(config, ':p')) : ''),
        \ 'args_after': ['-hF1', '-width(0,0)'] })

    let errorformat =
        \ '%E%f  %l  Error %n: %m,' .
        \ '%W%f  %l  Warning %n: %m,' .
        \ '%W%f  %l  Info %n: %m,' .
        \ '%-G%.%#'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'c',
    \ 'name': 'pc_lint',
    \ 'exec': 'lint-nt'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sts=4 sw=4:
