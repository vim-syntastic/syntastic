"============================================================================
"File:        python.vim
"Description: Syntax checking plugin for syntastic.vim
"============================================================================

if exists("g:loaded_syntastic_python_python_checker")
    finish
endif
let g:loaded_syntastic_python_python_checker=1

function! SyntaxCheckers_python_python_IsAvailable()
    return executable('python')
endfunction

function! SyntaxCheckers_python_python_GetLocList()
    let l:path = shellescape(expand('%'))
    let l:makeprg = 'python -m py_compile ' . l:path
    let l:errorformat = "%m\:\ ('%[%^']%#'\\\,\ ('%f'\\\,\ %l\\\,\ %c\\\,\ '%.%#'))"

    return SyntasticMake({ 'makeprg': l:makeprg, 'errorformat': l:errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'python',
    \ 'name': 'python'})
