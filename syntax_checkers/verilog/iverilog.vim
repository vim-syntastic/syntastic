"============================================================================
"File:        iverilog.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Psidium <psiidium at gmail dot com>
"============================================================================

if exists('g:loaded_syntastic_verilog_iverilog_checker')
    finish
endif
let g:loaded_syntastic_verilog_iverilog_checker = 1

if !exists('g:syntastic_verilog_compiler_options')
    let g:syntastic_verilog_compiler_options = '-Wall'
endif

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_verilog_iverilog_GetLocList() dict
    if !exists('g:syntastic_verilog_compiler')
        let g:syntastic_verilog_compiler = self.getExec()
    endif
    return syntastic#c#GetLocList('verilog', 'iverilog', {
        \ 'errorformat':
        \     '%f:%l: %trror: %m,' .
        \     '%f:%l: %tarning: %m',
        \ 'main_flags': '-t null' })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'verilog',
    \ 'name': 'iverilog'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
