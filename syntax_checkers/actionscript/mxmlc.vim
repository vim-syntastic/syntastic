"============================================================================
"File:        mxmlc.vim
"Description: ActionScript syntax checker - using mxmlc
"Maintainer:  Andy Earnshaw <andyearnshaw@gmail.com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"============================================================================

if exists("g:loaded_syntastic_actionscript_mxmlc_checker")
    finish
endif
let g:loaded_syntastic_actionscript_mxmlc_checker=1

if !exists("g:syntastic_actionscript_mxmlc_conf")
    let g:syntastic_actionscript_mxmlc_conf = ""
endif

function! SyntaxCheckers_actionscript_mxmlc_IsAvailable()
    return executable('mxmlc')
endfunction

function! SyntaxCheckers_actionscript_mxmlc_GetLocList()
    let output  = has("win32") ? 'NUL' : '/dev/null'
    let makeprg = syntastic#makeprg#build({
        \ 'exe': 'mxmlc',
        \ 'post_args': '-output=' . output . s:Args(),
        \ 'filetype': 'actionscript',
        \ 'subchecker': 'mxmlc' })

    let errorformat =
        \ '%f(%l): col: %c %trror: %m,' .
        \ '%f(%l): col: %c %tarning: %m,'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'defaults': {'bufnr': bufnr('')} })
endfunction

function s:Args()
    return !empty(g:syntastic_actionscript_mxmlc_conf) ? ' -load-config+=' . g:syntastic_actionscript_mxmlc_conf : ''
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'actionscript',
    \ 'name': 'mxmlc'})

