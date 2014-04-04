"============================================================================
"File:        svtools.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  LCD 47 <lcd047 at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists("g:loaded_syntastic_r_svtools_checker")
    finish
endif
let g:loaded_syntastic_r_svtools_checker = 1

if !exists('g:syntastic_r_svtools_styles')
    let g:syntastic_r_svtools_styles = 'lint.style'
endif

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_r_svtools_GetHighlightRegex(item)
    let term = matchstr(a:item['text'], "\\m'\\zs[^']\\+\\ze'")
    return term != '' ? '\V' . escape(term, '\') : ''
endfunction

function! SyntaxCheckers_r_svtools_IsAvailable() dict
    if !executable(self.getExec())
        return 0
    endif
    call system(self.getExecEscaped() . ' --slave --restore --no-save -e ' . syntastic#util#shescape('library(svTools)'))
    return v:shell_error == 0
endfunction

function! SyntaxCheckers_r_svtools_GetLocList() dict
    let makeprg = self.getExecEscaped() . ' --slave --restore --no-save' .
        \ ' -e ' . syntastic#util#shescape('library(svTools); ' .
        \       'try(lint(commandArgs(TRUE), filename = commandArgs(TRUE), type = "flat", sep = ":"))') .
        \ ' --args ' . syntastic#util#shexpand('%')

    let errorformat =
        \ '%trror:%f:%\s%#%l:%\s%#%v:%m,' .
        \ '%tarning:%f:%\s%#%l:%\s%#%v:%m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'returns': [0] })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'r',
    \ 'name': 'svtools',
    \ 'exec': 'R' })

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sts=4 sw=4:
