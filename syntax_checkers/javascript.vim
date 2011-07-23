"============================================================================
"File:        javascript.vim
"Description: Syntax checking plugin for syntastic.vim using jslin/jshint
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
" Added changes from Matthew Kitt's javascript.vim to support jshint.
" Will use jsl if it's found, if not it looks for jshint.
"============================================================================
if exists("loaded_javascript_syntax_checker")
    finish
endif
let loaded_javascript_syntax_checker = 1

" Use node jslint if the user has it installed
if executable("jslint")
    if !exists("g:syntastic_jslint_conf")
        let g:syntastic_jslint_conf = ""
    endif

    function! SyntaxCheckers_javascript_GetLocList()
        if empty(g:syntastic_jslint_conf)
            let jslintconf = ""
        else
            let jslintconf = g:syntastic_jslint_conf
        endif
        let makeprg = "jslint" . jslintconf . " " . shellescape(expand('%'))
        let errorformat='%-P%f,%*[ ]%n %l\,%c: %m,%-G%.%#'
        return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
    endfunction
    " We're using node jslint, finished.
    finish
endif

" Use jsl if the user has it installed
if executable("jsl")
    if !exists("g:syntastic_jsl_conf")
        let g:syntastic_jsl_conf = ""
    endif

    function! SyntaxCheckers_javascript_GetLocList()
        if empty(g:syntastic_jsl_conf)
            let jslconf = ""
        else
            let jslconf = " -conf " . g:syntastic_jsl_conf
        endif
        let makeprg = "jsl" . jslconf . " -nologo -nofilelisting -nosummary -nocontext -process ".shellescape(expand('%'))
        let errorformat='%W%f(%l): lint warning: %m,%-Z%p^,%W%f(%l): warning: %m,%-Z%p^,%E%f(%l): SyntaxError: %m,%-Z%p^,%-G'
        return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
    endfunction
    " We're using jsl, finished.
    finish
endif

" The user didn't have jsl, try with jshint instead
if !executable('jshint')
    finish
endif

function! SyntaxCheckers_javascript_GetLocList()
    if exists('s:config')
        let makeprg = 'jshint ' . shellescape(expand("%")) . ' --config ' . s:config
    else
        let makeprg = 'jshint ' . shellescape(expand("%"))
    endif
    let errorformat = '%f: line %l\, col %c\, %m,%-G%.%#'
    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction
