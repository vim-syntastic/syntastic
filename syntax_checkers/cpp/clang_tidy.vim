if exists("g:loaded_syntastic_cpp_clang_tidy_checker")
  finish
endif
let g:loaded_syntastic_cpp_clang_tidy_checker = 1

runtime! syntax_checkers/c/*.vim

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'cpp',
    \ 'name': 'clang_tidy',
    \ 'exec': 'clang-tidy',
    \ 'redirect': 'c/clang_tidy'})

" vim: set et sts=4 sw=4:
