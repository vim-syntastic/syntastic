"============================================================================
"File:        gcc.vim
"Description: Syntax checking for at&t and intel assembly files with gcc
"Maintainer:  Josh Rahm <joshuarahm@gmail.com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists('g:loaded_syntastic_asm_gcc_checker')
    finish
endif
let g:loaded_syntastic_asm_gcc_checker = 1

let s:asm_extensions = {
    \ 's': 'att',
    \ 'asm': 'intel'
    \ }

if !exists('g:syntastic_asm_compiler')
    let g:syntastic_asm_compiler = 'gcc'
endif

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_asm_gcc_IsAvailable() dict
    return executable(expand(g:syntastic_asm_compiler))
endfunction

if !exists('g:syntastic_asm_options')
    let g:syntastic_asm_options = ''
endif

function! SyntaxCheckers_asm_gcc_GetLocList() dict
    let compiler_options = s:GetDialect() . ' ' . g:syntastic_asm_options

    return syntastic#c#GetLocList('asm', 'gcc', {
        \ 'errorformat':
        \     '%-G%f:%s:,' .
        \     '%f:%l:%c: %trror: %m,' .
        \     '%f:%l:%c: %tarning: %m,' .
        \     '%f:%l: %m',
        \ 'main_flags': '-x assembler -fsyntax-only -masm=' . compiler_options , })
endfunction

function! s:GetDialect()
    if exists('g:syntastic_asm_dialect')
        return g:syntastic_asm_dialect
    endif

    let extensions = exists('g:syntastic_asm_extensions')
        \ ? g:syntastic_asm_extensions : s:asm_extensions 
    let dialect = get( extensions, tolower(expand('%:e')), 'att' )

    return dialect
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'asm',
    \ 'name': 'gcc'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sts=4 sw=4:
