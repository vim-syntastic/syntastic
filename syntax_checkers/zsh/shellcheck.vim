"============================================================================
"File:        shellcheck.vim
"Description: Shell script syntax/style checking plugin for syntastic.vim
"============================================================================

if exists('g:loaded_syntastic_zsh_shellcheck_checker')
    finish
endif
let g:loaded_syntastic_zsh_shellcheck_checker = 1
let g:syntastic_shellcheck_checker_shell = 'bash'

runtime! syntax_checkers/sh/*.vim

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'zsh',
    \ 'name': 'shellcheck',
    \ 'redirect': 'sh/shellcheck'})

" vim: set sw=4 sts=4 et fdm=marker:
