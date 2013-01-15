"============================================================================
"File:        typescript.vim
"Description: TypeScript syntax checker. For TypeScript v0.8.0
"Maintainer:  Bill Casarin <bill@casarin.ca>
"============================================================================

"bail if the user doesnt have tsc installed
if !executable("tsc")
    finish
endif

function! SyntaxCheckers_typescript_GetLocList()
    let makeprg = 'tsc ' . shellescape(expand("%")) . ' --out ' . syntastic#util#DevNull()
    let errorformat = '%f %#(%l\,%c): %m'
    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction
