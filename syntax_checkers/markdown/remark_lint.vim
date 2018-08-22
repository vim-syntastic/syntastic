"============================================================================
"File:        remark.vim
"Description: Syntax checking plugin for syntastic using remark-lint
"             (https://github.com/remarkjs/remark-lint)
"Maintainer:  Tim Carry <tim at pixelastic dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists('g:loaded_syntastic_markdown_remark_lint_checker')
    finish
endif
let g:loaded_syntastic_markdown_remark_lint_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_markdown_remark_lint_GetLocList() dict
    let makeprg = self.makeprgBuild({ 
          \'args_before': '--quiet --no-stdout --no-color' })

    let errorformat =
        \ '  %l:%c  %tarning  %m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'defaults': {'bufnr': bufnr('')},
        \ 'returns': [0] })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'markdown',
    \ 'name': 'remark_lint',
    \ 'exec': 'remark'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
