"============================================================================
"File:        rbenv.vim
"Description: Syntax checking plugin for syntastic.vim using rbenv ruby
"Maintainer:  Jacky Alcine <me@jalcine.me>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists("g:loaded_syntastic_ruby_rbenv_checker")
    finish
endif
let g:loaded_syntastic_ruby_rbenv_checker=1

if !exists("g:syntastic_rbenv_exec")
    let g:syntastic_rbenv_exec = system("rbenv which ruby") 
endif

function! SyntaxCheckers_ruby_rbenv_IsAvailable()
    return executable(expand(g:syntastic_rbenv_exec))
endfunction

function! SyntaxCheckers_ruby_rbenv_GetHighlightRegex(i)
    if match(a:i['text'], 'assigned but unused variable') > -1
        let term = split(a:i['text'], ' - ')[1]
        return '\V\<'.term.'\>'
    endif

    return ''
endfunction

function! SyntaxCheckers_ruby_rbenv_GetLocList()
    let exe = expand(g:syntastic_rbenv_exec)
    if !has('win32')
        let exe = 'RUBYOPT= ' . exe
    endif

    let makeprg = syntastic#makeprg#build({
        \ 'exe': exe,
        \ 'args': '-w -T1 -c',
        \ 'filetype': 'ruby',
        \ 'subchecker': 'rbenv' })

    "this is a hack to filter out a repeated useless warning in rspec files
    "containing lines like
    "
    "  foo.should == 'bar'
    "
    "Which always generate the warning below. Note that ruby >= 1.9.3 includes
    "the word "possibly" in the warning
    let errorformat = '%-G%.%#warning: %\(possibly %\)%\?useless use of == in void context,'

    " filter out lines starting with ...
    " long lines are truncated and wrapped in ... %p then returns the wrong
    " column offset
    let errorformat .= '%-G%\%.%\%.%\%.%.%#,'

    let errorformat .=
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
    \ 'name': 'rbenv'})
