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

if !exists("g:syntastic_puppet_lint_disable")
    let g:syntastic_puppet_lint_disable = 0
endif

if !executable("puppet-lint")
    let g:syntastic_puppet_lint_disable = 1
endif

function! s:PuppetExtractVersion()
    let output = system("puppet --version")
    let output = substitute(output, '\n$', '', '')
    return split(output, '\.')
endfunction

function! s:PuppetLintExtractVersion()
    let output = system("puppet-lint --version")
    let output = substitute(output, '\n$', '', '')
    let output = substitute(output, '^puppet-lint ', '', 'i')
    return split(output, '\.')
endfunction

let s:puppetVersion = s:PuppetExtractVersion()
let s:lintVersion = s:PuppetLintExtractVersion()

if !(s:lintVersion[0] >= '0' && s:lintVersion[1] >= '1' && s:lintVersion[2] >= '10')
    let g:syntastic_puppet_lint_disable = 1
endif

function! s:getPuppetLintErrors()
    if !exists("g:syntastic_puppet_lint_arguments")
        let g:syntastic_puppet_lint_arguments = ''
    endif

    let makeprg = 'puppet-lint --log-format "\%{KIND} [\%{check}] \%{message} at \%{fullpath}:\%{linenumber}" '.g:syntastic_puppet_lint_arguments.shellescape(expand('%'))
    let errorformat = '%t%*[a-zA-Z] %m at %f:%l'
    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat, 'subtype': 'Style' })
endfunction

function! s:getPuppetMakeprg() 
    "If puppet is >= version 2.7 then use the new executable
    if s:puppetVersion[0] >= '2' && s:puppetVersion[1] >= '7'
        let makeprg = 'puppet parser validate ' .
                    \ shellescape(expand('%')) .
                    \ ' --color=false'

        "add --ignoreimport for versions < 2.7.10
        if s:puppetVersion[2] < '10'
            let makeprg .= ' --ignoreimport'
        endif

    else
        let makeprg = 'puppet --color=false --parseonly --ignoreimport '.shellescape(expand('%'))
    endif
    return makeprg
endfunction

function! SyntaxCheckers_puppet_GetLocList()

    let makeprg = s:getPuppetMakeprg()

    "some versions of puppet (e.g. 2.7.10) output the message below if there
    "are any syntax errors
    let errorformat = '%-Gerr: Try ''puppet help parser validate'' for usage,'
    let errorformat .= 'err: Could not parse for environment %*[a-z]: %m at %f:%l'

    let errors = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
 
    if !g:syntastic_puppet_lint_disable
        let errors = errors + s:getPuppetLintErrors()
    endif

    return errors
endfunction

