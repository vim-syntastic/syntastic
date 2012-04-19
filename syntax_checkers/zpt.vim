"============================================================================
"File:        zpt.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  claytron <robots at claytron dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

" In order for this plugin to be useful, you will need to set up the
" zpt filetype in your vimrc
"
"    " set up zope page templates as the zpt filetype
"    au BufNewFile,BufRead *.pt,*.cpt,*.zpt set filetype=zpt syntax=xml
"
" Then install the zptlint program, found on pypi:
" http://pypi.python.org/pypi/zptlint

if exists("loaded_zpt_syntax_checker")
    finish
endif
let loaded_zpt_syntax_checker = 1

" Bail if the user doesn't have zptlint installed
if !executable("zptlint")
    finish
endif

function! SyntaxCheckers_zpt_GetLocList()
    let makeprg="zptlint ".shellescape(expand('%'))
    let errorformat='%-P*** Error in: %f,%Z%*\s\, at line %l\, column %c,%E%*\s%m,%-Q'
    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction
