"============================================================================
"File:        rstcheck.vim
"Description: Syntax checking for reStructuredText and embedded code blocks
"Authors:     Steven Myint <git@stevenmyint.com>
"
"============================================================================
"
" Checker option:
"
" - g:syntastic_rst_rstcheck_ignore_errors(list; default: [])
"   list of errors to ignore

if exists('g:loaded_syntastic_rst_rstcheck_checker')
    finish
endif
let g:loaded_syntastic_rst_rstcheck_checker = 1

if !exists('g:syntastic_rst_rstcheck_ignore_errors')
    let g:syntastic_rst_rstcheck_ignore_errors = []
endif

let s:save_cpo = &cpo
set cpo&vim

" TODO: configure any default errors to ignore
let s:ignore_errors = []

function! s:IgnoreError(text)
    for i in s:ignore_errors + g:syntastic_rst_rstcheck_ignore_errors
        if stridx(a:text, i) != -1
            return 1
        endif
    endfor
    return 0
endfunction

function! SyntaxCheckers_rst_rstcheck_GetLocList() dict
    let makeprg = self.makeprgBuild({})

    let errorformat =
        \ '%f:%l: (%tNFO/1) %m,'.
        \ '%f:%l: (%tARNING/2) %m,'.
        \ '%f:%l: (%tRROR/3) %m,'.
        \ '%f:%l: (%tEVERE/4) %m,'.
        \ '%-G%.%#'

    let loclist = SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'returns': [0, 1] })

    for e in loclist
        if e['valid'] && s:IgnoreError(e['text']) == 1
            let e['valid'] = 0
        else
            if e['type'] ==? 'S'
                let e['type'] = 'E'
            elseif e['type'] ==? 'I'
                let e['type'] = 'W'
                let e['subtype'] = 'Style'
            endif
        endif
    endfor

    return loclist
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'rst',
    \ 'name': 'rstcheck'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
