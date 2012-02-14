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

function! s:ExtractVersion()
    let output = system("puppet --version")
    let output = substitute(output, '\n$', '', '')
    return split(output, '\.')
endfunction

let s:puppetVersion = s:ExtractVersion()

function! SyntaxCheckers_puppet_GetLocList()
    "If puppet is >= version 2.7 then use the new executable
    if s:puppetVersion[0] >= '2' && s:puppetVersion[1] >= '7'
        let makeprg = 'puppet parser validate ' .
                    \ shellescape(expand('%')) .
                    \ ' --color=false' .
                    \ ' --storeconfigs'

        "add --ignoreimport for versions < 2.7.10
        if s:puppetVersion[2] < '10'
            let makeprg .= ' --ignoreimport'
        endif

    else
        let makeprg = 'puppet --color=false --parseonly --ignoreimport '.shellescape(expand('%'))
    endif

    "some versions of puppet (e.g. 2.7.10) output the message below if there
    "are any syntax errors
    let errorformat = '%-Gerr: Try ''puppet help parser validate'' for usage,'

    let errorformat .= 'err: Could not parse for environment %*[a-z]: %m at %f:%l'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction
