"============================================================================
"File:        ycm.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Val Markovic <val at markovic dot io>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists("g:loaded_syntastic_c_ycm_checker")
    finish
endif
let g:loaded_syntastic_c_ycm_checker = 1

function! SyntaxCheckers_c_ycm_IsAvailable() dict
    return exists('g:loaded_youcompleteme')
endfunction

if !exists('g:loaded_youcompleteme')
    finish
endif

function! SyntaxCheckers_c_ycm_GetLocList() dict
    let errors = youcompleteme#CurrentFileDiagnostics()
    " filter the processed errors if desired
    if exists('g:syntastic_c_remove_include_errors') && g:syntastic_c_remove_include_errors != 0
        return filter(errors, 'has_key(v:val, "bufnr") && v:val["bufnr"] == ' . bufnr(''))
    else
        return errors
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'c',
    \ 'name': 'ycm'})
