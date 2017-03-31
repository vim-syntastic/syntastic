"============================================================================
"File:        gom.vim
"Description: Check go syntax using 'gofmt -l' followed by 'gom [build|test]'
"Maintainer:  Yves Lange <kursion@gmail.com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
" In order to use gom instead of go, you should add
" let g:syntastic_go_checkers = ['gom', 'gofmt', 'golint', 'govet']
" to your VIM configuration file.
"
"
" This syntax checker does not reformat your source code.
" Use a BufWritePre autocommand to that end:
"   autocmd FileType go autocmd BufWritePre <buffer> Fmt
"============================================================================

if exists("g:loaded_syntastic_go_gom_checker")
    finish
endif
let g:loaded_syntastic_go_gom_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_go_gom_IsAvailable() dict
    return executable('gom') && executable('gofmt')
endfunction

function! SyntaxCheckers_go_gom_GetLocList() dict
    " Check with gofmt first, since `gom build` and `gom test` might not report
    " syntax errors in the current file if another file with syntax error is
    " compiled first.
    let makeprg = self.makeprgBuild({
        \ 'exe': 'gofmt',
        \ 'args': '-l',
        \ 'tail': '> ' . syntastic#util#DevNull() })

    let errorformat =
        \ '%f:%l:%c: %m,' .
        \ '%-G%.%#'

    let errors = SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'defaults': {'type': 'e'} })
    if !empty(errors)
        return errors
    endif

    " Test files, i.e. files with a name ending in `_test.go`, are not
    " compiled by `gom build`, therefore `gom test` must be called for those.
    if match(expand('%'), '\m_test\.go$') == -1
        let makeprg = 'gom build ' . syntastic#c#NullOutput()
        let cleanup = 0
    else
        let makeprg = 'gom test -c ' . syntastic#c#NullOutput()
        let cleanup = 1
    endif

    " The first pattern is for warnings from C compilers.
    let errorformat =
        \ '%W%f:%l: warning: %m,' .
        \ '%E%f:%l:%c:%m,' .
        \ '%E%f:%l:%m,' .
        \ '%C%\s%\+%m,' .
        \ '%-G#%.%#'

    " The go compiler needs to either be run with an import path as an
    " argument or directly from the package directory. Since figuring out
    " the proper import path is fickle, just cwd to the package.

    let errors = SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'cwd': expand('%:p:h'),
        \ 'defaults': {'type': 'e'} })

    if cleanup
        call delete(expand('%:p:h') . syntastic#util#Slash() . expand('%:p:h:t') . '.test')
    endif

    return errors
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'go',
    \ 'name': 'gom'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sts=4 sw=4:
