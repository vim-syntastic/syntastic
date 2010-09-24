"============================================================================
"File:        perl.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Anthony Carapetis <anthony.carapetis at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

" This checker requires efm_perl.pl, which is distributed with Vim version
" seven and greater, as far as I know.

if exists("loaded_perl_syntax_checker")
    finish
endif
let loaded_perl_syntax_checker = 1

"bail if the user doesnt have perl installed
if !executable("perl")
    finish
endif

function! SyntaxCheckers_perl_GetLocList()
    let makeprg = $VIMRUNTIME.'/tools/efm_perl.pl -c '.shellescape(expand('%'))
    let errorformat =  '%f:%l:%m'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction
