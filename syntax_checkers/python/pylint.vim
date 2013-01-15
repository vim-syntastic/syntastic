"============================================================================
"File:        pylint.vim
"Description: Syntax checking plugin for syntastic.vim
"Author:      Parantapa Bhattacharya <parantapa at gmail dot com>
"
"============================================================================
function! SyntaxCheckers_python_GetLocList()
    let makeprg = 'pylint '.g:syntastic_python_checker_args.' -f parseable -r n -i y ' .
                \ shellescape(expand('%')) .
                \ ' 2>&1 \| sed ''s_: \[\([RCW]\)_: \[W] \[\1_''' .
                \ ' \| sed ''s_: \[\([FE]\)_:\ \[E] \[\1_'''
    let errorformat = '%f:%l: [%t] %m,%Z,%-GNo config %m'
    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction
