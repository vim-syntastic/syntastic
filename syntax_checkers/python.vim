if exists("loaded_python_syntax_checker")
    finish
endif
let loaded_python_syntax_checker = 1

"bail if the user doesnt have pyflakes installed
if !executable("pyflakes")
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

function! SyntaxCheckers_python_GetLocList()
    let makeprg = 'pyflakes '.shellescape(expand('%'))
    let errorformat = '%E%f:%l: could not compile,%-Z%p^,%W%f:%l: %m,%-G%.%#'

    let errors = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

    call syntastic#HighlightErrors(errors, function('SyntaxCheckers_python_Term'))

    return errors
endfunction
