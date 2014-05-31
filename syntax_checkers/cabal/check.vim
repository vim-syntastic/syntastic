"============================================================================
"File:        check.vim
"Description: Haskell package description (.cabal file) linting and syntax
"             validation via 'cabal check'
"Maintainer: Ian D. Bollinger <ian.bollinger@gmail.com>
"License:    This program is free software. It comes without any warranty,
"            to the extent permitted by applicable law. You can redistribute
"            it and/or modify it under the terms of the Do What The Fuck You
"            Want To Public License, Version 2, as published by Sam Hocevar.
"            See http://sam.zoy.org/wtfpl/COPYING for more details.
"============================================================================

if exists('g:loaded_syntastic_cabal_check_checker')
    finish
endif
let g:loaded_syntastic_cabal_check_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_cabal_check_GetHighlightRegex(item)
    let field = matchstr(a:item['text'], "\\vParse of field '\\zs[^']+")
    if field != ''
        return '\v\c^\s*' . field . '\s*:\s*\zs.*$'
    endif
    return ''
endfunction

function! SyntaxCheckers_cabal_check_GetLocList() dict
    let makeprg = self.makeprgBuild({'exe_after': 'check', 'fname': ''})
    let errorformat =
        \ '%Ecabal: %f:%l: %m,' .
        \ '%W* %m,'
    let old_pwd = getcwd()
    execute 'cd ' . syntastic#util#shexpand('%:h')
    let loclist = SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'defaults': {'bufnr': bufnr('%'), 'lnum': 1}})
    execute 'cd ' . old_pwd
    return loclist
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'cabal',
    \ 'name': 'check',
    \ 'exec': 'cabal'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sts=4 sw=4:
