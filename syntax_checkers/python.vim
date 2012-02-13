"============================================================================
"File:        python.vim
"Description: Syntax checking plugin for syntastic.vim
"
"Authors:     Martin Grenfell <martin.grenfell@gmail.com>
"             kstep <me@kstep.me>
"             Parantapa Bhattacharya <parantapa@gmail.com>
"
"============================================================================
"
" For forcing the use of flake8, pyflakes, or pylint set
"
"   let g:syntastic_python_checker = 'pyflakes'
"
" in your .vimrc. Default is flake8.

if exists("loaded_python_syntax_checker")
    finish
endif
let loaded_python_syntax_checker = 1

"bail if the user doesnt have his favorite checker or flake8 or pyflakes installed
if !exists('g:syntastic_python_checker') || !executable(g:syntastic_python_checker)
    if executable("flake8")
        let g:syntastic_python_checker = 'flake8'
    elseif executable("pyflakes")
        let g:syntastic_python_checker = 'pyflakes'
    elseif executable("pylint")
        let g:syntastic_python_checker = 'pylint'
    else
        finish
    endif
endif
if !exists('g:syntastic_python_checker_args')
    let g:syntastic_python_checker_args = ''
endif

function! SyntaxCheckers_python_Term(i)
    if a:i['type'] ==# 'E'
        let a:i['text'] = "Syntax error"
    endif
    if match(a:i['text'], 'is assigned to but never used') > -1
                \ || match(a:i['text'], 'imported but unused') > -1
                \ || match(a:i['text'], 'undefined name') > -1
                \ || match(a:i['text'], 'redefinition of') > -1
                \ || match(a:i['text'], 'referenced before assignment') > -1
                \ || match(a:i['text'], 'duplicate argument') > -1
                \ || match(a:i['text'], 'after other statements') > -1
                \ || match(a:i['text'], 'shadowed by loop variable') > -1

        let term = split(a:i['text'], "'", 1)[1]
        return '\V\<'.term.'\>'
    endif
    return ''
endfunction

if g:syntastic_python_checker == 'pylint'
    function! SyntaxCheckers_python_GetLocList()
        let makeprg = 'pylint -f parseable -r n -i y ' .
            \ shellescape(expand('%')) .
            \ ' \| sed ''s_: \[[RC]_: \[W_''' .
            \ ' \| sed ''s_: \[[F]_:\ \[E_'''
        let errorformat = '%f:%l: [%t%n] %m,%-GNo config%m'
        let errors = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

        return errors
    endfunction
else
    function! SyntaxCheckers_python_GetLocList()
        let makeprg = g:syntastic_python_checker.' '.g:syntastic_python_checker_args.' '.shellescape(expand('%'))
        let errorformat =
            \ '%E%f:%l: could not compile,%-Z%p^,%W%f:%l:%c: %m,%W%f:%l: %m,%-G%.%#'

        let errors = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

        call SyntasticHighlightErrors(errors, function('SyntaxCheckers_python_Term'))

        return errors
    endfunction
endif
