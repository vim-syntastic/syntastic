"============================================================================
"File: nagelfar.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer: James Pickard <james.pickard at gmail dot com>
"License: This program is free software. It comes without any warranty,
" to the extent permitted by applicable law. You can redistribute
" it and/or modify it under the terms of the Do What The Fuck You
" Want To Public License, Version 2, as published by Sam Hocevar.
" See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
function! SyntaxCheckers_tcl_GetLocList()
    let makeprg = "nagelfar -H " . g:syntastic_tcl_nagelfar_conf . " " . shellescape(expand('%'))

    let errorformat='%I%f: %l: N %m, %f: %l: %t %m, %-GChecking file %f'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction
