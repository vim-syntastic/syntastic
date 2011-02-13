"============================================================================
"File:        less.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Julien Blanchard <julien at sideburns dot eu>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists("loaded_less_syntax_checker")
    finish
endif
let loaded_less_syntax_checker = 1

"bail if the user doesnt have the lessc binary installed
if !executable("lessc")
    finish
endif

function! SyntaxCheckers_less_GetLocList()
    let makeprg = 'lessc '. shellescape(expand('%'))
    let errorformat = 'Syntax %trror on line %l,! Syntax %trror: on line %l: %m,%-G%.%#'
    let errors = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

    for i in errors
        let i['bufnr'] = bufnr("")

        if empty(i['text'])
            let i['text'] = "Syntax error"
        endif
    endfor

    return errors
endfunction
