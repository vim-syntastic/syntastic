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

"Support passing configuration directives to phpcs
if !exists("g:syntastic_phpcs_conf")
    let g:syntastic_phpcs_conf = ""
endif

if !exists("g:syntastic_phpcs_disable")
    let g:syntastic_phpcs_disable = 0
endif

function! SyntaxCheckers_php_Term(item)
    let unexpected = matchstr(a:item['text'], "unexpected '[^']\\+'")
    if len(unexpected) < 1 | return '' | end
    return '\V'.split(unexpected, "'")[1]
endfunction

function! SyntaxCheckers_php_GetLocList()

    let errors = []

    let makeprg = "php -l -d error_reporting=E_PARSE -d display_errors=1 ".shellescape(expand('%'))
    let errorformat='%-GNo syntax errors detected in%.%#,PHP Parse error: %#syntax %trror\, %m in %f on line %l,PHP Fatal %trror: %m in %f on line %l,%-GErrors parsing %.%#,%-G\s%#,Parse error: %#syntax %trror\, %m in %f on line %l,Fatal %trror: %m in %f on line %l'
    let errors = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

    if empty(errors) && !g:syntastic_phpcs_disable && executable("phpcs")
        let errors = errors + s:GetPHPCSErrors()
    endif

    call SyntasticHighlightErrors(errors, function('SyntaxCheckers_php_Term'))

    return errors
endfunction

function! s:GetPHPCSErrors()
    let makeprg = "phpcs " . g:syntastic_phpcs_conf . " --report=csv ".shellescape(expand('%'))
    let errorformat = '%-GFile\,Line\,Column\,Type\,Message\,Source\,Severity,"%f"\,%l\,%c\,%t%*[a-zA-Z]\,"%m"\,%*[a-zA-Z0-9_.-]\,%*[0-9]'
    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat, 'subtype': 'Style' })
endfunction
