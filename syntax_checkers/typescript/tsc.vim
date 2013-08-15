"============================================================================
"File:        typescript.vim
"Description: TypeScript syntax checker. For TypeScript v0.8 and v0.9
"Maintainer:  Bill Casarin <bill@casarin.ca>
"============================================================================

if exists("g:loaded_syntastic_typescript_tsc_checker")
    finish
endif
let g:loaded_syntastic_typescript_tsc_checker=1

function! SyntaxCheckers_typescript_tsc_IsAvailable()
    return executable("tsc")
endfunction

function! SyntaxCheckers_typescript_tsc_GetLocList()
    let makeprg = syntastic#makeprg#build({
        \ 'exe': 'tsc',
        \ 'post_args': '--module commonjs --out ' . syntastic#util#DevNull(),
        \ 'filetype': 'typescript',
        \ 'subchecker': 'tsc' })

    let errorformat =
        \ '%E%f(%l\,%c):\ error\ TS%n: %m,' .
        \ '%Eerror\ TS%n:\ %m,' .
        \ '%E%f(%l\,%c): %m,' .
        \ '%C\	%m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'typescript',
    \ 'name': 'tsc'})
