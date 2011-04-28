"============================================================================
"File:        puppet.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Eivind Uggedal <eivind at uggedal dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists("loaded_puppet_syntax_checker")
    finish
endif
let loaded_puppet_syntax_checker = 1

"bail if the user doesnt have puppet installed
if !executable("puppet")
    finish
endif

function! SyntaxCheckers_puppet_GetLocList()
    let makeprg = 'puppet --color=false --parseonly '.shellescape(expand('%'))
    let errorformat = 'err: Could not parse for environment %*[a-z]: %m at %f:%l'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction
