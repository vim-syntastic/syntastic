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
    let exe = expand(g:syntastic_ruby_exec)
    if !has('win32')
        let exe = 'RUBYOPT= ' . exe
    endif

    let fname = fnameescape(expand('%'))

    let enc = &fileencoding != '' ? &fileencoding : &encoding
    let encoding_string = enc ==? 'utf-8' ? 'UTF-8' : 'BINARY'

    " TODO: fix the encoding trainwreck
    let makeprg =
        \ exe . ' -e ' .
        \ shellescape('puts File.read("' . fname .
        \     '", :encoding => "' . encoding_string .
        \     '").gsub(''<\%='',''<\%'')') .
        \ ' \| ' . g:syntastic_erb_exec . ' -x -T -' .
        \ ' \| ' . exe . ' -c'

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
