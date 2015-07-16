"============================================================================
"File:        sqlint.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Steve Purcell <steve@sanityinc.com>
"License:     MIT
"============================================================================

if exists('g:loaded_syntastic_sql_sqlint_checker')
    finish
endif
let g:loaded_syntastic_sql_sqlint_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_sql_sqlint_IsAvailable() dict
    if !executable(self.getExec())
        return 0
    endif
    return syntastic#util#versionIsAtLeast(self.getVersion(), [0, 0, 3])
endfunction

function! SyntaxCheckers_sql_sqlint_GetLocList() dict
    let makeprg = self.makeprgBuild({})

    let commonformat = '%f:%l:%c:'
    let errorformat =
        \ '%E%>' . commonformat . "ERROR %m," .
        \ '%+C%>  %.%#,' .
        \ '%W%>' . commonformat . "WARNING %m," .
        \ '%+C%>  %.%#'
    let loclist = SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'subtype': 'Style'})

    return loclist
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'sql',
    \ 'name': 'sqlint'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
