"============================================================================
"File:        typescript.vim
"Description: TypeScript syntax checker
"Maintainer:  Bill Casarin <bill@casarin.ca>
"============================================================================

if exists("g:loaded_syntastic_typescript_tsc_checker")
    finish
endif
let g:loaded_syntastic_typescript_tsc_checker = 1

if !exists('g:syntastic_typescript_tsc_sort')
    let g:syntastic_typescript_tsc_sort = 1
endif

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_typescript_tsc_GetLocList() dict
    if syntastic#util#isRunningWindows()
        " On Windows, tsc is unable to use 'NUL'.
        let makeprg = self.makeprgBuild({
            \ 'args': '--module commonjs',
            \ 'args_after': '--outDir ' . $temp })
    else
        let makeprg = self.makeprgBuild({
            \ 'args': '--module commonjs',
            \ 'args_after': '--out ' . syntastic#util#DevNull() })
    endif

    let errorformat =
        \ '%E%f %#(%l\,%c): error %m,' .
        \ '%E%f %#(%l\,%c): %m,' .
        \ '%Eerror %m,' .
        \ '%C%\s%\+%m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'defaults': {'bufnr': bufnr("")} })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'typescript',
    \ 'name': 'tsc'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
