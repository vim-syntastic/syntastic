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
    let l:puppetVersion = system("puppet --version")
    let l:digits = split(l:puppetVersion, "\\.")
    "
    " If it is on the 2.7 series... use new executable
    if l:digits[0] == '2' && l:digits[1] == '7'
      let makeprg = 'puppet parser validate ' . 
            \ shellescape(expand('%')) .
            \ ' --color=false'
    else
      let makeprg = 'puppet --color=false --parseonly '.shellescape(expand('%'))
    endif

    let errorformat = 'err: Could not parse for environment %*[a-z]: %m at %f:%l'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction
