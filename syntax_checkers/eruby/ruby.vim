"============================================================================
"File:        eruby.vim
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

if !exists("g:syntastic_ruby_exec")
    let g:syntastic_ruby_exec = "ruby"
endif

function! SyntaxCheckers_eruby_ruby_IsAvailable()
    return executable(expand(g:syntastic_ruby_exec))
endfunction

function! SyntaxCheckers_eruby_ruby_GetLocList()
    let exe = expand(g:syntastic_ruby_exec)
    if !has('win32')
        let exe = 'RUBYOPT= ' . exe
    endif

    let fname = fnameescape(expand('%'))

    let enc = &fileencoding != '' ? &fileencoding : &encoding
    let encoding_string = enc ==# 'utf-8' ? ', :encoding => "UTF-8"' : ''

    "gsub fixes issue #7, rails has it's own eruby syntax
    let makeprg =  'erb -xT - ' . fname . ' \| ruby -c'

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
    \ 'name': 'ruby'})
