"============================================================================
"File:        bashate.vim
"Description: Bash script style checking plugin for syntastic.vim
"Notes:       bashate is a pep8 equivalent for bash scripts
"             Can be downloaded from:
"             https://pypi.python.org/pypi/bashate or
"             https://github.com/openstack-dev/bashate
"============================================================================

if exists("g:loaded_syntastic_sh_bashate_checker")
    finish
endif
let g:loaded_syntastic_sh_bashate_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_sh_bashate_GetLocList() dict
    let makeprg = self.makeprgBuild({})

    let errorformat =
        \ '%EE%n: %m: %.%#,%Z - %f : L%l'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'subtype': 'Style' })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'sh',
    \ 'name': 'bashate' })

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sts=4 sw=4:
