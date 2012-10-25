"============================================================================
"File:        gofmt.vim
"Description: Check go syntax using gofmt
"Maintainer:  Brandon Thomson <bt@brandonthomson.com>
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
    " format the file. The default is for `gofmt` to just print to STDOUT.
    if g:syntastic_go_checker_option_gofmt_write == 1
        let makeprg = 'gofmt -w %'
    else
        let makeprg = 'gofmt %'
    endif
    let errorformat = '%f:%l:%c: %m,%-G%.%#'

    let errors = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat, 'defaults': {'type': 'e'} })

    " Do not reload buffer if errors were found.
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

    return errors
endfunction
