"============================================================================
"File:        mypy.vim
"Description: Syntax checking plugin for syntastic.vim
"Author:      Russ Hewgill <Russ dot Hewgill at gmail dot com>
"
"============================================================================

if exists("g:loaded_syntastic_python_mypy_checker")
    finish
endif
let g:loaded_syntastic_python_mypy_checker = 1

function! SyntaxCheckers_python_mypy_IsAvailable() dict
    return executable(self.getExec())
endfunction

function! SyntaxCheckers_python_mypy_GetLocList() dict
    let makeprg = self.makeprgBuild({
                    \ 'args': '',
                    \ 'args_after': '' })

    let errorformat = '%f\, line %l: %m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'returns': [0,1] })
endfunction


call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'python',
    \ 'name': 'mypy'})



