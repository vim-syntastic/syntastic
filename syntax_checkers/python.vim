if exists("loaded_python_syntax_checker")
    finish
endif
let loaded_python_syntax_checker = 1

"bail if the user doesnt have pyflakes installed
if !executable("pyflakes") || !executable("grep")
    finish
endif

function! SyntaxCheckers_python_GetLocList()
    let makeprg = 'pyflakes '.shellescape(expand('%'))
    let errorformat = '%E%f:%l: could not compile,%-Z%p^,%W%f:%l: %m,%-G%.%#'

    let errors = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

    call clearmatches()
    for i in errors
        if i['type'] ==# 'E'
            let i['text'] = "Syntax error"
        endif
        if match(i['text'], 'is assigned to but never used') > -1
                    \ || match(i['text'], 'imported but unused') > -1
                    \ || match(i['text'], 'undefined name') > -1
                    \ || match(i['text'], 'redefinition of unused') > -1
            let term = split(i['text'], "'", 1)[1]
            call matchadd('SpellBad', '\%' . i['lnum'] . 'l\<' . term . '\>')
        endif
    endfor

    return errors
endfunction
