"============================================================================
"File:        gnumake.vim
"Description: Syntax checking plugin for makefiles.
"Maintainer:  Steven Myint
"
"============================================================================

if exists("g:loaded_syntastic_make_make_checker")
    finish
endif
let g:loaded_syntastic_make_make_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_make_gnumake_IsAvailable() dict
    let exe = self.getExec()
    return executable(exe) && system(exe . ' --version') =~# '^GNU Make ' && v:shell_error == 0
endfunction

function! SyntaxCheckers_make_gnumake_GetLocList() dict
    let makeprg = self.makeprgBuild({
        \ 'args_after': '-s -n',
        \ 'fname_before': '-f' })

    let errorformat = '%f:%l: %m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'returns': [0, 2] })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'make',
    \ 'name': 'gnumake',
    \ 'exec': 'make' })

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sts=4 sw=4:
