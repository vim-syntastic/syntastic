if exists("g:loaded_syntastic_cpp_clang_check_checker")
  finish
endif
let g:loaded_syntastic_cpp_clang_check_checker = 1

runtime! syntax_checkers/c/*.vim

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'cpp',
    \ 'name': 'clang_check',
    \ 'exec': 'clang-check',
    \ 'redirect': 'c/clang_check'})

" vim: set et sts=4 sw=4:
