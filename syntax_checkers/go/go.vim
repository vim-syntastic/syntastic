"============================================================================
"File:        go.vim
"Description: Check go syntax using 'go build'
"Maintainer:  Kamil Kisiel <kamil@kamilkisiel.net>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
" Use `let g:syntastic_go_checker_option_gofmt_write=1` to allow gofmt to
" format the source file. Default: disabled.
"============================================================================
function! SyntaxCheckers_go_GetLocList()

    " Check the g:syntastic_go_checker_option_gofmt_write variable.
    if !exists("g:syntastic_go_checker_option_gofmt_write")
        let g:syntastic_go_checker_option_gofmt_write = 0
    endif

    " Use gofmt to check the syntax for the current file.
    " If the syntastic_go_checker_option_gofmt_write is set to 1, let `gofmt`
    " format the file. The default is for `gofmt` to just prints to STDOUT.
    if g:syntastic_go_checker_option_gofmt_write == 1
        let makeprg = 'gofmt -w %'
    else
        let makeprg = 'gofmt %'
    endif
    let errorformat = '%f:%l:%c: %m,%-G%.%#'

    let errors = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat, 'defaults': {'type': 'e'} })

    " Do not perform further checks if errors were found.
    if !empty(errors)
        return errors
    endif

    " If the content of the file might have been changed due to
    " g:syntastic_go_checker_option_gofmt_write being enabled, the buffer must
    " be reloaded.
    if g:syntastic_go_checker_option_gofmt_write == 1
        let view = winsaveview()
        silent %!cat %
        call winrestview(view)
    endif

    " Check syntax with the go compiler.
    " Test files, i.e. files with a name ending in `_test.go`, are not
    " compiled by `go build`, therefore `go test` must be called for those.
    if match(expand('%'), '_test.go$') == -1
        let makeprg = 'go build -o /dev/null'
    else
        let makeprg = 'go test -c -o /dev/null'
    endif
    let errorformat = '%f:%l:%c:%m,%f:%l%m,%-G#%.%#'

    " The go compiler needs to either be run with an import path as an
    " argument or directly from the package directory. Since figuring out
    " the poper import path is fickle, just pushd/popd to the package.
    let popd = getcwd()
    let pushd = expand('%:p:h')
    "
    " pushd
    exec 'lcd ' . fnameescape(pushd)

    let errors = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

    " popd
    exec 'lcd ' . fnameescape(popd)

    return errors
endfunction
