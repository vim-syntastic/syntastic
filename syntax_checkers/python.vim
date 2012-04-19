"============================================================================
"File:        python.vim
"Description: Syntax checking plugin for syntastic.vim
"
"Authors:     Martin Grenfell <martin.grenfell@gmail.com>
"             kstep <me@kstep.me>
"             Parantapa Bhattacharya <parantapa@gmail.com>
"
"
" For forcing the use of flake8, pyflakes, or pylint set
"
"   let g:syntastic_python_checker = 'pyflakes'
"
" in your .vimrc. Default is flake8.
"============================================================================

if exists("loaded_python_syntax_checker")
    finish
endif
let loaded_python_syntax_checker = 1

if !exists('g:syntastic_python_checker_args')
    let g:syntastic_python_checker_args = ''
endif

let s:supported_checkers = ["flake8", "pyflakes", "pylint"]
call SyntasticLoadChecker(s:supported_checkers, 'python')
