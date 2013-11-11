"============================================================================
"File:        flake8.vim
"Description: Syntax checking plugin for syntastic.vim
"Authors:     Sylvain Soliman <Sylvain dot Soliman+git at gmail dot com>
"             kstep <me@kstep.me>
"
"============================================================================
if exists("g:loaded_syntastic_python_flake8_checker")
    finish
endif
let g:loaded_syntastic_python_flake8_checker=1

function! SyntaxCheckers_python_flake8_GetHighlightRegex(i)
    return SyntaxCheckers_python_pyflakes_GetHighlightRegex(a:i)
endfunction

function! SyntaxCheckers_python_flake8_GetLocList() dict
    let makeprg = self.makeprgBuild({})

    let errorformat =
        \ '%E%f:%l: could not compile,%-Z%p^,' .
        \ '%E%f:%l:%c: F%n %m,' .
        \ '%W%f:%l:%c: C%n %m,' .
        \ '%W%f:%l:%c: %.%n %m,' .
        \ '%W%f:%l: %.%n %m,' .
        \ '%-G%.%#'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat })
endfunction

runtime! syntax_checkers/python/pyflakes.vim

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'python',
    \ 'name': 'flake8'})
