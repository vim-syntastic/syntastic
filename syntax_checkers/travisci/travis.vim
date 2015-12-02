"============================================================================
"File:        travisci.vim
"Description: Syntax checking plugin for syntastic.vim
"Authors:     Joel Frederico <joelfred at slac dot stanford dot edu>
"
"============================================================================
if exists('g:loaded_syntastic_travisci_travis_checker')
    finish
endif
let g:loaded_syntastic_travisci_travis_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_travisci_travis_GetLocList() dict
    let makeprg = self.makeprgBuild({
                \ 'args': 'lint',
                \ 'args_after': '' })

    let errorformat = 
        \ '[x] syntax error: (<unknown>): %m at line %l column %c,' .
	\ '[x] %m,'
	" \ '[x] %m %s\, dropping,' .


    let env = {}

    let loclist = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat, 'env': env })

    for e in loclist
    endfor

    return loclist
endfunction


call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'travisci',
    \ 'name': 'travis'})
