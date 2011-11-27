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
"
" Use g:syntastic_javascript_checker option to specify which jslint executable
" should be used (see below for a list of supported checkers).
" If g:syntastic_javascript_checker is not set, just use the first syntax
" checker that we find installed.
"
" Some work could be done here to remove the duplication of the *_conf
" variables. A single variable could be used here.
"
"============================================================================
if exists("loaded_javascript_syntax_checker")
    finish
endif
let loaded_javascript_syntax_checker = 1

let s:supported_checkers = ["gjslint", "jslint", "jsl", "jshint"]

let s:checker = ""
if exists("g:syntastic_javascript_checker")
    let s:checker = g:syntastic_javascript_checker
    if !executable(s:checker) || index(s:supported_checkers, s:checker) == -1
        echoerr "Javascript syntax not supported or not installed."
    endif
else
    " Use whichever syntax checker we find installed first
    if executable("gjslint")
        let s:checker = "gjslint"
    elseif executable("jslint")
        let s:checker = "jslint"
    elseif executable("jsl")
        let s:checker = "jsl"
    elseif executable("jshint")
        let s:checker = "jshint"
    endif
endif

if s:checker == "gjslint"
    if !exists("g:syntastic_gjslint_conf")
        let g:syntastic_gjslint_conf = ""
    endif

    function! SyntaxCheckers_javascript_GetLocList()
        if empty(g:syntastic_gjslint_conf)
            let gjslintconf = ""
        else
            let gjslintconf = g:syntastic_gjslint_conf
        endif
        let makeprg = "gjslint" . gjslintconf . " --nosummary --unix_mode --nodebug_indentation --nobeep " . shellescape(expand('%'))
        let errorformat="%f:%l:(New Error %n) %m,%f:%l:(%n) %m,%-G1 files checked, no errors found.,%-G%.%#"
        return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
    endfunction

elseif s:checker == "jslint"
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

elseif s:checker == "jsl"
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

elseif s:checker == 'jshint'
    function! SyntaxCheckers_javascript_GetLocList()
        if exists('s:config')
            let makeprg = 'jshint ' . shellescape(expand("%")) . ' --config ' . s:config
        else
            let makeprg = 'jshint ' . shellescape(expand("%"))
        endif
        let errorformat = '%f: line %l\, col %c\, %m,%-G%.%#'
        return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
    endfunction
endif
