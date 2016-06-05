"============================================================================
"File:        cuda.vim
"Description: Syntax checking plugin for syntastic
"Authors:     Hannes Schulz <schulz at ais dot uni-bonn dot de>
"             Nils Moehrle <nils at kuenstle-moehrle dot de>
"============================================================================

if exists('g:loaded_syntastic_cuda_nvcc_checker')
    finish
endif
let g:loaded_syntastic_cuda_nvcc_checker = 1

if !exists('g:syntastic_cuda_config_file')
    let g:syntastic_cuda_config_file = '.syntastic_cuda_config'
endif

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_cuda_nvcc_GetLocList() dict
    let buildoptions = {
        \ 'args_before': '--cuda -O0 -I . ' .
        \ syntastic#c#ReadConfig(g:syntastic_cuda_config_file) .
        \ ' -Xcompiler -fsyntax-only',
        \ 'tail_after': syntastic#c#NullOutput()}

    if index(['h', 'hpp', 'cuh'], expand('%:e', 1), 0, 1) >= 0
        if syntastic#util#var('cuda_check_header', 0)
            let buildoptions.exe_before = 'touch /tmp/.syntastic_dummy.cu ;'
            let buildoptions.fname = '/tmp/.syntastic_dummy.cu'
            let buildoptions.args_after = '-include ' . syntastic#util#shexpand('%')
        else
            return []
        endif
    endif
    let makeprg = self.makeprgBuild(buildoptions)

    let errorformat =
        \ '%*[^"]"%f"%*\D%l: %m,'.
        \ '"%f"%*\D%l: %m,'.
        \ '%-G%f:%l: (Each undeclared identifier is reported only once,'.
        \ '%-G%f:%l: for each function it appears in.),'.
        \ '%f:%l:%c:%m,'.
        \ '%f(%l):%m,'.
        \ '%f:%l:%m,'.
        \ '"%f"\, line %l%*\D%c%*[^ ] %m,'.
        \ '%D%*\a[%*\d]: Entering directory `%f'','.
        \ '%X%*\a[%*\d]: Leaving directory `%f'','.
        \ '%D%*\a: Entering directory `%f'','.
        \ '%X%*\a: Leaving directory `%f'','.
        \ '%DMaking %*\a in %f,'.
        \ '%f|%l| %m'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'cuda',
    \ 'name': 'nvcc'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
