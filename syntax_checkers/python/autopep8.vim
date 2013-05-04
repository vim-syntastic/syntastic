"============================================================================
"File:        autopep8.vim
"Description: Syntax checking plugin for syntastic.vim
"Authors:     Zhao Cai <caizhaoff@gmail.com>
"
"============================================================================
if exists("g:loaded_syntastic_python_autopep8_checker")
    finish
endif
let g:loaded_syntastic_python_autopep8_checker=1

function! SyntaxCheckers_python_autopep8_IsAvailable()
    return executable('autopep8')
endfunction

function! SyntaxCheckers_python_autopep8_GetLocList()
    let makeprg = syntastic#makeprg#build({
                \ 'exe': 'autopep8',
                \ 'args': ' --in-place --aggressive --jobs=0',
                \ 'subchecker': 'autopep8' })
    let errorformat = '%m'
    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'python',
    \ 'name': 'autopep8'})
