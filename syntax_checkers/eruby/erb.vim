"============================================================================
"File:        erb.vim
"Description: Syntax checking plugin for syntastic.vim
"Author:      Martin Grenfell <martin.grenfell at gmail dot com>
"Modifier:    Grzegorz Smajdor <grzegorz.smajdor at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"============================================================================

if exists("g:loaded_syntastic_eruby_erb_checker")
    finish
endif
let g:loaded_syntastic_eruby_erb_checker=1

if !exists("g:syntastic_erb_exec")
    let g:syntastic_erb_exec = "erb"
endif

if !exists("g:syntastic_ruby_exec")
    let g:syntastic_ruby_exec = "ruby"
endif

function! SyntaxCheckers_eruby_erb_IsAvailable()
    return executable(expand(g:syntastic_ruby_exec)) && executable(expand(g:syntastic_ruby_exec))
endfunction

function! SyntaxCheckers_eruby_erb_GetLocList()
    " TODO: fix the encoding trainwreck
    " let enc = &fileencoding != '' ? &fileencoding : &encoding
    let enc = ''

    let makeprg = syntastic#makeprg#build({
        \ 'exe': g:syntastic_erb_exec,
        \ 'args': '-x -T -' . (enc ==# 'utf-8' ? ' -U' : ''),
        \ 'tail': '\| ' . g:syntastic_ruby_exec .  ' -c',
        \ 'filetype': 'eruby',
        \ 'subchecker': 'erb' })

    let errorformat =
        \ '%-GSyntax OK,'.
        \ '%E-:%l: syntax error\, %m,%Z%p^,'.
        \ '%W-:%l: warning: %m,'.
        \ '%Z%p^,'.
        \ '%-C%.%#'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'defaults': { 'bufnr': bufnr(""), 'vcol': 1 } })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'eruby',
    \ 'name': 'erb'})
