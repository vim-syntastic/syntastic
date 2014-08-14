if exists("g:loaded_syntastic_c_clang_tidy_checker")
  finish
endif
let g:loaded_syntastic_c_clang_tidy_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_c_clang_tidy_IsAvailable() dict
  return executable(self.getExec())
endfunction

function! SyntaxCheckers_c_clang_tidy_GetLocList() dict
    let makeprg = self.makeprgBuild({})

    let errorformat = '%f:%l:%c: %m'

    let loclist = SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat})

    call self.setWantSort(1)

    return loclist
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'c',
    \ 'name': 'clang_tidy',
    \ 'exec': 'clang-tidy'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sts=4 sw=4:
