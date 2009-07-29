if exists("loaded_python_syntax_checker")
    finish
endif
let loaded_python_syntax_checker = 1

"bail if the user doesnt have pyflakes installed
if !executable("pyflakes")
    finish
endif

function! SyntaxCheckers_python_GetLocList()
    let makeprg = 'pyflakes %'
    let errorformat = '%E%f:%l: could not compile,%-Z%p^,%W%f:%l: %m,%-G%.%#'

    let errors = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

    for i in errors
        if i['type'] ==# 'E'
            let i['text'] = "Syntax error"
        endif
    endfor

    return errors
endfunction
