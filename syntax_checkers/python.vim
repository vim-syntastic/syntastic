if exists("loaded_python_syntax_checker")
    finish
endif
let loaded_python_syntax_checker = 1

" If neither pyflakes nor flake8 exist, bail out
if !executable("pyflakes") && !executable("flake8")
    finish
endif

function! SyntaxCheckers_python_Term(i)
    if a:i['type'] ==# 'E'
        let a:i['text'] = "Syntax error"
    endif
    if match(a:i['text'], 'is assigned to but never used') > -1
                \ || match(a:i['text'], 'imported but unused') > -1
                \ || match(a:i['text'], 'undefined name') > -1
                \ || match(a:i['text'], 'redefinition of unused') > -1

        let term = split(a:i['text'], "'", 1)[1]
        return '\V'.term
    endif
    return ''
endfunction

" Use flake8 if it is installed
if executable("flake8")
    function! SyntaxCheckers_python_GetLocList()
        let makeprg="flake8 ".shellescape(expand('%'))
        let errorformat='%f:%l:%c:\ E%n\ %m,%f:%l:%c:\ %m,%f:%l:\ %m'

        let errors = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

        call syntastic#HighlightErrors(errors, function('SyntaxCheckers_python_Term'))

        return errors
    endfunction
    " We are using flake8, finished.
    finish
endif

" User didn't have flake8 installed, try pyflakes instead
if !executable("pyflakes")
    finish
endif

function! SyntaxCheckers_python_GetLocList()
    let makeprg = 'pyflakes '.shellescape(expand('%'))
    let errorformat = '%E%f:%l: could not compile,%-Z%p^,%W%f:%l: %m,%-G%.%#'

    let errors = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

    call syntastic#HighlightErrors(errors, function('SyntaxCheckers_python_Term'))

    return errors
endfunction
