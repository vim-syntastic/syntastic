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
"============================================================================
function! SyntaxCheckers_go_GetLocList()

    " Use go fmt first
    " This call to go fmt writes out to disk, we'll update the buffer later
    let makeprg = 'go fmt %'
    let errorformat = '%f:%l:%c: %m,%-G%.%#'
    let errors = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat, 'defaults': {'type': 'e'} })
    if !empty(errors)
        return errors
    endif

    " Update the buffer
    let view = winsaveview()
    silent %!gofmt
    call winrestview(view)

    " Use go [build,test]
    if match(expand("%"), "test.go") == -1
        let makeprg = 'go build -o /dev/null'
    else
        let makeprg = 'go test -c -o /dev/null'
    endif
    let errorformat = '%f:%l:%c:%m,%f:%l%m,%-G#%.%#'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction
