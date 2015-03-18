"============================================================================
"File:        mercury.vim
"Description: Syntax checking plugin for syntastic.vim
"             Based off of the hlint syntax checker.
"Maintainer:  Josh Rahm (joshuarahm@gmail.com)
"License:     WTF
"============================================================================

if exists('g:loaded_syntastic_mercury_mmc_checker')
    finish
endif
let g:loaded_syntastic_mercury_mmc_checker = 1

if !exists('g:syntastic_mercury_compiler_options')
    let g:syntastic_mercury_compiler_options=''
endif

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_mercury_mmc_GetLocList() dict
    let makeprg = self.makeprgBuild({
      \  'exe': self.getExecEscaped() . ' -e ' . g:syntastic_mercury_compiler_options})

    let errorformat =
        \ '%E%f:%l:   error:%m,' .
        \ '%E%f:%l: Error:%m,' .
        \ '%W%f:%l:   warning:%m,' .
        \ '%E%f:%l:   mode error:%m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'postprocess': ['compressWhitespace'] })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'mercury',
    \ 'name': 'mmc'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sts=4 sw=4:
