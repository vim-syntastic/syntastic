if exists('g:loaded_syntastic_rmd_lintr_checker')
    finish
endif
let g:loaded_syntastic_rmd_lintr_checker = 1

runtime! syntax_checkers/r/lintr.vim

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'rmd',
    \ 'name': 'lintr',
    \ 'redirect': 'r/lintr'})

" vim: set et sts=4 sw=4:
