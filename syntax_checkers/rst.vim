"============================================================================
"File:        rst.vim
"Description: Syntax checking plugin for docutil's reStructuredText files
"Maintainer:  James Rowe <jnrowe at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

" We use rst2pseudoxml.py, as it is ever so marginally faster than the other
" rst2${x} tools in docutils.

if exists("loaded_rst_syntax_checker")
    finish
endif
let loaded_rst_syntax_checker = 1

"bail if the user doesn't have rst2pseudoxml.py installed
if !executable("rst2pseudoxml.py")
    finish
endif

function! SyntaxCheckers_rst_GetLocList()
    let makeprg = 'rst2pseudoxml.py --report=2 --exit-status=1 ' .
      \ shellescape(expand('%')) . ' ' . syntastic#util#DevNull()

    let errorformat = '%f:%l:\ (%tNFO/1)\ %m,
      \%f:%l:\ (%tARNING/2)\ %m,
      \%f:%l:\ (%tRROR/3)\ %m,
      \%f:%l:\ (%tEVERE/4)\ %m,
      \%-G%.%#'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction
