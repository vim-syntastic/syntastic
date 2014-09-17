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

" stolen from c.vim of syntastic




function! getLintFile(file) 
    " search in the current file's directory upwards
    let config = findfile(a:file, '.;')
    if config == '' || !filereadable(config)
      return ''
    endif

    " convert filename into absolute path
    return '-i"' . fnamemodify(config, ':p:h') . '"'
endfunction


if !exists('g:syntastic_pc_lint_config_file')
    let g:syntastic_pc_lint_config_file = '.lnt'
endif

function! SyntaxCheckers_c_pc_lint_GetLocList() dict
    " gotta add something about the options file
    let makeprg = self.makeprgBuild({
        \ 'args': ' -hF1 -width(0,0)' })

    let errorformat =
        \ '%f %l %trror %n: %m,' .
        \ '%f %l %tarning %n: %m,' .
        \ '%f %l %tnfo %n: %m'

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
