"============================================================================
"File:        ruby.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists("g:loaded_syntastic_eruby_ruby_checker")
    finish
endif
let g:loaded_syntastic_eruby_ruby_checker=1

if !exists("g:syntastic_erb_exec")
    let g:syntastic_erb_exec = "erb"
endif

if !exists("g:syntastic_ruby_exec")
    let g:syntastic_ruby_exec = "ruby"
endif

function! SyntaxCheckers_eruby_ruby_IsAvailable()
    return executable(expand(g:syntastic_erb_exec)) && executable(expand(g:syntastic_ruby_exec))
endfunction

function! SyntaxCheckers_eruby_ruby_Preprocess(errors)
    let out = copy(a:errors)
    for n in range(len(out))
        let out[n] = substitute(out[n], '\V<%=', '<%', 'g')
    endfor
    return out
endfunction

function! SyntaxCheckers_eruby_ruby_GetLocList()
    " TODO: do something about the encoding
    let makeprg = syntastic#makeprg#build({
        \ 'exe': expand(g:syntastic_erb_exec),
        \ 'args': '-x -T -',
        \ 'tail': ' | ' . expand(g:syntastic_ruby_exec) .  ' -c',
        \ 'filetype': 'eruby',
        \ 'subchecker': 'ruby' })

    let errorformat =
        \ '%-GSyntax OK,'.
        \ '%E-:%l: syntax error\, %m,%Z%p^,'.
        \ '%W-:%l: warning: %m,'.
        \ '%Z%p^,'.
        \ '%-C%.%#'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'preprocess': 'SyntaxCheckers_eruby_ruby_Preprocess',
        \ 'defaults': { 'bufnr': bufnr(""), 'vcol': 1 } })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'eruby',
    \ 'name': 'ruby'})
