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
    let makeprg = 'go build -o /dev/null'
    let errorformat = '%f:%l:%c:%m,%f:%l%m,%-G#%.%#'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction
