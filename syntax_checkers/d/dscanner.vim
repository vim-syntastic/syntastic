"============================================================================
"File:        dscanner.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  ANtlord
"
"============================================================================

if exists('g:loaded_syntastic_d_dscanner_checker')
    finish
endif
let g:loaded_syntastic_d_dscanner_checker = 1

if !exists('g:syntastic_d_dscanner_sort')
    let g:syntastic_d_dscanner_sort = 1
endif

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_d_dscanner_IsAvailable() dict
    let exec_file = self.getExec()
    let is_exec = executable(exec_file)
    if !is_exec
        call self.log('Syntastic: D-Scanner executable file not found.')
    endif
    return is_exec
endfunction

function! SyntaxCheckers_d_dscanner_GetLocList() dict
    let makeprg = self.makeprgBuild({
                \ 'args': '--report',
                \ 'tail': '2>/dev/null',
                \ 'args_after': '' })

    let errorformat = '%f:%l:%c:%m'
    let loclist = SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'preprocess': 'dscanner'})
    return loclist
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
            \ 'filetype': 'd',
            \ 'name': 'dscanner',
            \ 'exec': 'dscanner' })

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
