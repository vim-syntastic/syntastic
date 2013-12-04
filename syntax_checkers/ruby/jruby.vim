"============================================================================
"File:        jruby.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Leonid Shevtsov <leonid at shevtsov dot me>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists("g:loaded_syntastic_ruby_jruby_checker")
    finish
endif
let g:loaded_syntastic_ruby_jruby_checker=1

function! SyntaxCheckers_ruby_jruby_GetLocList() dict
    if syntastic#util#isRunningWindows()
        let exe = self.getExec()
        let args = '-W1 -T1 -c'
    else
        let exe = 'RUBYOPT= ' . self.getExec()
        let args = '-W1 -c'
    endif

    let makeprg = self.makeprgBuild({ 'exe': exe, 'args': args })

    let errorformat =
        \ '%-GSyntax OK for %f,'.
        \ '%ESyntaxError in %f:%l: syntax error\, %m,'.
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
    \ 'name': 'jruby'})
