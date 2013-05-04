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

if !exists('g:syntastic_autopep8_agressive')
    let g:syntastic_autopep8_agressive = 0
endif

function! SyntaxCheckers_python_autopep8_IsAvailable()
    return executable('autopep8')
endfunction

function! SyntaxCheckers_python_autopep8_GetLocList()
    let args = ' --in-place --jobs=0'
    if g:syntastic_autopep8_agressive
        let args = args.' --aggressive'
    endif
    let makeprg = syntastic#makeprg#build({
                \ 'exe': 'autopep8',
                \ 'args': args ,
                \ 'subchecker': 'autopep8' })
    let errorformat = '%m'
    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'python',
    \ 'name': 'autopep8'})
