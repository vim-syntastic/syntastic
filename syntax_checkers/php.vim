"============================================================================
"File:        php.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists("loaded_php_syntax_checker")
    finish
endif
let loaded_php_syntax_checker = 1

"bail if the user doesnt have php installed
if !executable("php")
    finish
endif

function! SyntaxCheckers_php_Term(item)
    let unexpected = matchstr(a:item['text'], "unexpected '[^']\\+'")
    if len(unexpected) < 1 | return '' | end
    return '\V'.split(unexpected, "'")[1]
endfunction

function! SyntaxCheckers_php_GetLocList()

    let errors = []

    let no_phpcs = exists("g:syntastic_phpcs_disable") && g:syntastic_phpcs_disable

    " Run phpcs if it is found, and if it is not disabled.
    if executable("phpcs") && !no_phpcs
        " Support passing configuration directives to phpcs through
        " g:syntastic_phpcs_conf. This matches the method in the javascript.vim
        " setup.
        if !exists("g:syntastic_phpcs_conf") || empty(g:syntastic_phpcs_conf)
          let phpcsconf = ""
        else
          let phpcsconf = g:syntastic_phpcs_conf
        endif
        let makeprg = "phpcs " . phpcsconf . " --report=csv ".shellescape(expand('%'))
        let errorformat = '"%f"\,%l\,%c\,%t%*[a-zA-Z]\,"%m"\,%*[a-zA-Z0-9_.-]\,%*[0-9]'
        let errors = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
    endif

    let makeprg = "php -l ".shellescape(expand('%'))
    let errorformat='%-GNo syntax errors detected in%.%#,PHP Parse error: %#syntax %trror\, %m in %f on line %l,PHP Fatal %trror: %m in %f on line %l,%-GErrors parsing %.%#,%-G\s%#,Parse error: %#syntax %trror\, %m in %f on line %l,Fatal %trror: %m in %f on line %l'
    let errors = errors + SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

    call SyntasticHighlightErrors(errors, function('SyntaxCheckers_php_Term'))

    return errors
endfunction
