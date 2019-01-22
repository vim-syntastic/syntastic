"============================================================================
"File:        validator.vim
"Description: Syntax checking plugin for syntastic
"Maintainer:  LCD 47 <lcd047 at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists('g:loaded_syntastic_html_validator_checker')
    finish
endif
let g:loaded_syntastic_html_validator_checker=1

let s:save_cpo = &cpo
set cpo&vim

" Constants {{{1

let s:DEFAULTS = {
    \ 'api':      'https://validator.nu/',
    \ 'nsfilter': '',
    \ 'parser':   '',
    \ 'schema':   '' }

let s:CONTENT_TYPE = {
    \ 'html': 'text/html',
    \ 'svg':  'image/svg+xml',
    \ 'xhtm': 'application/xhtml+xml' }

" }}}1

" @vimlint(EVL101, 1, l:api)
" @vimlint(EVL101, 1, l:nsfilter)
" @vimlint(EVL101, 1, l:parser)
" @vimlint(EVL101, 1, l:schema)
function! SyntaxCheckers_html_validator_GetLocList() dict " {{{1
    let buf = bufnr('')
    let type = self.getFiletype()
    let fname = syntastic#util#shescape(fnamemodify(bufname(buf), ':p'))

    for key in keys(s:DEFAULTS)
        let l:{key} = syntastic#util#var(type . '_validator_' . key, get(s:DEFAULTS, key))
    endfor
    let ctype = get(s:CONTENT_TYPE, type, '')

    " vint: -ProhibitUsingUndeclaredVariable
    let makeprg = self.getExecEscaped() . ' -q -L -s --compressed -F out=gnu -F asciiquotes=yes' .
        \ (nsfilter !=# '' ? ' -F nsfilter=' . syntastic#util#shescape(nsfilter) : '') .
        \ (parser !=# '' ? ' -F parser=' . parser : '') .
        \ (schema !=# '' ? ' -F schema=' . syntastic#util#shescape(schema) : '') .
        \ ' -F doc=@' . fname .
            \ (ctype !=# '' ? '\;type=' . ctype : '') .
            \ '\;filename=' . fname .
        \ ' ' . api
    " vint: ProhibitUsingUndeclaredVariable

    let errorformat =
        \ '%E"%f":%l: %trror: %m,' .
        \ '%E"%f":%l-%\d%\+: %trror: %m,' .
        \ '%E"%f":%l%\%.%c: %trror: %m,' .
        \ '%E"%f":%l%\%.%c-%\d%\+%\%.%\d%\+: %trror: %m,' .
        \ '%E"%f":%l: %trror fatal: %m,' .
        \ '%E"%f":%l-%\d%\+: %trror fatal: %m,' .
        \ '%E"%f":%l%\%.%c: %trror fatal: %m,' .
        \ '%E"%f":%l%\%.%c-%\d%\+%\%.%\d%\+: %trror fatal: %m,' .
        \ '%W"%f":%l: info %tarning: %m,' .
        \ '%W"%f":%l-%\d%\+: info %tarning: %m,' .
        \ '%W"%f":%l%\%.%c: info %tarning: %m,' .
        \ '%W"%f":%l%\%.%c-%\d%\+%\%.%\d%\+: info %tarning: %m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'preprocess': 'validator',
        \ 'returns': [0] })
endfunction " }}}1
" @vimlint(EVL101, 0, l:schema)
" @vimlint(EVL101, 0, l:parser)
" @vimlint(EVL101, 0, l:nsfilter)
" @vimlint(EVL101, 0, l:api)

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'html',
    \ 'name': 'validator',
    \ 'exec': 'curl' })

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
