"============================================================================
"File:        ncverilog.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  limelightful
"============================================================================

if exists('g:loaded_syntastic_verilog_ncverilog_checker')
    finish
endif
let g:loaded_syntastic_verilog_ncverilog_checker = 1

if !exists('g:syntastic_verilog_compiler_options')
    let g:syntastic_verilog_compiler_options = '-q '
endif

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_verilog_ncverilog_IsAvailable() dict
    if !exists('g:syntastic_verilog_compiler')
        let g:syntastic_verilog_compiler = self.getExec()
    endif
    call self.log('g:syntastic_verilog_compiler =', g:syntastic_verilog_compiler)
    return executable(expand(g:syntastic_verilog_compiler, 1))
endfunction

function! SyntaxCheckers_verilog_ncverilog_GetLocList() dict
    return syntastic#c#GetLocList('verilog', 'ncverilog', {
        \ 'errorformat':
        \     'nc%[a-z]%#: %\%#%t\,%[A-Z]%# (%f\,%l|%c): %m',
        \ 'main_flags': '-elaborate' })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'verilog',
    \ 'name': 'ncverilog' })

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
