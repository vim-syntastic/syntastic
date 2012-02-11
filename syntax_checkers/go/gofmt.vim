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
"============================================================================

function! SyntaxCheckers_go_GetLocList()
    let makeprg = 'gofmt %'

    " If there are no syntax errors gofmt will write the formatted source to
    " stdout which will make a big honking mess in the location list. So
    " override the default shellpipe to get messages only from stderr. Also
    " send stdout to /dev/null so the screen won't have to be :redraw'n
    " whenever there are no errors)
    let shellpipe = '1>/dev/null 2>'

    let errorformat = '%E%f:%l:%c: %m'

    return SyntasticMake({ 'makeprg': makeprg, 'shellpipe': shellpipe, 'errorformat': errorformat })
endfunction
