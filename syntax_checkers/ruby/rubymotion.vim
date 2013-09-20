"============================================================================
"File:        rubymotion.vim
"Description: Syntax checking plugin for syntastic.vim
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists("g:loaded_syntastic_ruby_rubymotion_checker")
    finish
endif
let g:loaded_syntastic_ruby_rubymotion_checker=1

function! SyntaxCheckers_ruby_rubymotion_IsAvailable()
    return executable('/Library/RubyMotion/bin/ruby')
endfunction

function! SyntaxCheckers_ruby_rubymotion_GetLocList()
    let makeprg = syntastic#makeprg#build({
        \ 'exe': 'RUBYOPT= /Library/RubyMotion/bin/ruby',
        \ 'args': '-W1 -c',
        \ 'filetype': 'ruby',
        \ 'subchecker': 'rubymotion' })

    let errorformat =
        \ '%-GSyntax OK,'.
        \ '%E%f:%l: syntax error\, %m,'.
        \ '%Z%p^,'.
        \ '%W%f:%l: warning: %m,'.
        \ '%Z%p^,'.
        \ '%W%f:%l: %m,'.
        \ '%-C%.%#'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'ruby',
    \ 'name': 'rubymotion'})
