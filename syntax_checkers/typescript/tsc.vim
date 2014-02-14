"============================================================================
"File:        typescript.vim
"Description: TypeScript syntax checker
"Maintainer:  Bill Casarin <bill@casarin.ca>
"============================================================================

if exists("g:loaded_syntastic_typescript_tsc_checker")
    finish
endif
let g:loaded_syntastic_typescript_tsc_checker = 1

if !exists('g:syntastic_typescript_args')
    let g:syntastic_typescript_args = '--module commonjs'
endif

if !exists('g:syntastic_typescript_post_args')
    let g:syntastic_typescript_post_args = '--out ' . syntastic#util#DevNull()
endif

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_typescript_tsc_GetLocList() dict
    let makeprg = self.makeprgBuild({
        \ 'args': g:syntastic_typescript_args,
        \ 'post_args': g:syntastic_typescript_post_args })

    let errorformat =
        \ '%E%f %#(%l\,%c): error %m,' .
        \ '%E%f %#(%l\,%c): %m,' .
        \ '%Eerror %m,' .
        \ '%C%\s%\+%m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'defaults': {'bufnr': bufnr("")},
        \ 'postprocess': ['sort'] })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'typescript',
    \ 'name': 'tsc'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sts=4 sw=4:
