"============================================================================
"File:        hdevtools.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Anthony Carapetis <anthony.carapetis at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

function! SyntaxCheckers_haskell_GetLocList()
    let makeprg = 'hdevtools check ' . get(g:, 'hdevtools_options', '') .
                \ ' ' . shellescape(expand('%'))

    let errorformat= '\%-Z\ %#,'.
                \ '%W%f:%l:%c:\ Warning:\ %m,'.
                \ '%E%f:%l:%c:\ %m,'.
                \ '%E%>%f:%l:%c:,'.
                \ '%+C\ \ %#%m,'.
                \ '%W%>%f:%l:%c:,'.
                \ '%+C\ \ %#%tarning:\ %m,'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction

function! SyntaxCheckers_lhaskell_GetLocList()
    return SyntaxCheckers_haskell_GetLocList()
endfunction
