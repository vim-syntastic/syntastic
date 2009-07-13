"============================================================================
"File:        eruby.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin_grenfell at msn dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists("loaded_eruby_syntax_checker")
    finish
endif
let loaded_eruby_syntax_checker = 1

"bail if the user doesnt have ruby or cat installed
if !executable("ruby") || !executable("cat")
    finish
endif

function! SyntaxCheckers_eruby_GetLocList()
    let &makeprg='cat '. expand("%") . ' \| ruby -e "require \"erb\"; puts ERB.new(ARGF.read, nil, \"-\").src" \| ruby -c'
    set errorformat=%-GSyntax\ OK,%E-:%l:\ syntax\ error\\,\ %m,%Z%p^,%W-:%l:\ warning:\ %m,%Z%p^,%-C%.%#
    silent lmake!

    "the file name isnt in the output so stick in the buf num manually
    let loclist = getloclist(0)
    for i in loclist
        let i['bufnr'] = bufnr("")
    endfor

    return loclist
endfunction
