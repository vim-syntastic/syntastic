"============================================================================
"File:        w3.vim
"Description: Syntax checking plugin for syntastic
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists('g:loaded_syntastic_html_w3_checker')
    finish
endif
let g:loaded_syntastic_html_w3_checker = 1

let s:save_cpo = &cpo
set cpo&vim

" Constants {{{1

let s:DEFAULTS = {
    \ 'html': {
        \ 'ctype':   'text/html',
        \ 'doctype': 'HTML5' },
    \ 'svg': {
        \ 'ctype':   'image/svg+xml',
        \ 'doctype': 'SVG 1.1' },
    \ 'xhtml': {
        \ 'ctype':   'application/xhtml+xml',
        \ 'doctype': 'XHTML 1.1' } }

" }}}1

" @vimlint(EVL101, 1, l:ctype)
" @vimlint(EVL101, 1, l:doctype)
function! SyntaxCheckers_html_w3_GetLocList() dict " {{{1
    let buf = bufnr('')
    let type = self.getFiletype()
    let fname = syntastic#util#shescape(fnamemodify(bufname(buf), ':p'))
    let api = syntastic#util#var(type . '_w3_api', 'https://validator.w3.org/check')

    for key in keys(s:DEFAULTS[type])
        let l:{key} = syntastic#util#var(type . '_w3_' . key, get(s:DEFAULTS[type], key))
    endfor

    " vint: -ProhibitUsingUndeclaredVariable
    let makeprg = self.getExecEscaped() . ' -q -L -s --compressed -F output=json' .
        \ (doctype !=# '' ? ' -F doctype=' . syntastic#util#shescape(doctype) : '') .
        \ ' -F uploaded_file=@' . fname .
            \ '\;type=' . ctype .
            \ '\;filename=' . fname .
        \ ' ' . api
    " vint: ProhibitUsingUndeclaredVariable

    let errorformat =
        \ '%A %\+{,' .
        \ '%C %\+"lastLine": %l\,%\?,' .
        \ '%C %\+"lastColumn": %c\,%\?,' .
        \ '%C %\+"message": "%m"\,%\?,' .
        \ '%C %\+"type": "%trror"\,%\?,' .
        \ '%-G %\+"type": "%tnfo"\,%\?,' .
        \ '%C %\+"subtype": "%tarning"\,%\?,' .
        \ '%Z %\+}\,,' .
        \ '%-G%.%#'

    let loclist = SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'defaults': {'bufnr': bufnr('')},
        \ 'returns': [0] })

    for e in loclist
        let e['text'] = substitute(e['text'], '\m\\\([\"]\)', '\1', 'g')
    endfor

    return loclist
endfunction " }}}1
" @vimlint(EVL104, 0, l:doctype)
" @vimlint(EVL101, 0, l:ctype)

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'html',
    \ 'name': 'w3',
    \ 'exec': 'curl' })

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
