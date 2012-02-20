"============================================================================
"File:        pylint.vim
"Description: Syntax checking plugin for syntastic.vim
"Author:      Parantapa Bhattacharya <parantapa at gmail dot com>
"
"============================================================================
function! SyntaxCheckers_python_GetLocList()
    let makeprg = 'pylint -f parseable -r n -i y ' .
                \ shellescape(expand('%')) .
                \ ' \| sed ''s_: \[[RC]_: \[W_''' .
                \ ' \| sed ''s_: \[[F]_:\ \[E_'''
    let errorformat = '%f:%l: [%t%n] %m,%-GNo config%m'
    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction
