"============================================================================
"File:        haskell.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Anthony Carapetis <anthony.carapetis at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists("loaded_haskell_syntax_checker")
    finish
endif
let loaded_haskell_syntax_checker = 1

"bail if the user doesnt have ghc installed
if !executable("ghc")
    finish
endif

" As this calls ghc, it can take a few seconds... maybe hlint or something
" could do a good enough job?
function! SyntaxCheckers_haskell_GetLocList()
    let makeprg = 'ghc % -e :q'
    let errorformat = '%-G\\s%#,%f:%l:%c:%m,%E%f:%l:%c:,%Z%m,'


    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction
