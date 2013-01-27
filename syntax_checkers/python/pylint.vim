"============================================================================
"File:        pylint.vim
"Description: Syntax checking plugin for syntastic.vim
"Author:      Parantapa Bhattacharya <parantapa at gmail dot com>
"
"============================================================================
function! SyntaxCheckers_python_pylint_IsAvailable()
    return executable('pylint')
endfunction

function! SyntaxCheckers_python_pylint_GetLocList()
    let makeprg = syntastic#makeprg#build({
                \ 'exe': 'pylint',
                \ 'args': ' -f parseable -r n -i y',
                \ 'tail': s:MakeprgTail(),
                \ 'subchecker': 'pylint' })
    let errorformat = '%f:%l: [%t] %m,%Z,%-GNo config %m'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction

function! s:MakeprgTail()
    return ' 2>&1 \| sed ''s_: \[\([RCW]\)_: \[W] \[\1_''' .
         \ ' \| sed ''s_: \[\([FE]\)_:\ \[E] \[\1_'''
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'python',
    \ 'name': 'pylint' })
