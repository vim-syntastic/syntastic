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
"
"This syntax checker is composed of three checkers:
"   - php -l
"   - phpcs (see http://pear.php.net/package/PHP_CodeSniffer)
"   - phpmd (see http://phpmd.org)
"
"If any of these checkers are installed then they will be used. Phpcs and
"Phpmd are 'style checkers' and will only be called if `php -l` doesnt find
"any syntax errors.
"
"There are options below to config and disable phpcs and phpmd.


"bail if the user doesnt have php installed
if !executable("php")
    finish
endif

"Support passing configuration directives to phpcs
if !exists("g:syntastic_phpcs_conf")
    let g:syntastic_phpcs_conf = ""
endif

if !exists("g:syntastic_phpcs_disable") || !executable('phpcs')
    let g:syntastic_phpcs_disable = 0
endif


if !exists("g:syntastic_phpmd_disable") || !executable('phpmd')
    let g:syntastic_phpmd_disable = 0
endif


"Support passing selected rules to phpmd
if !exists("g:syntastic_phpmd_rules")
    let g:syntastic_phpmd_rules = "codesize,design,unusedcode,naming"
endif

function! SyntaxCheckers_php_GetHighlightRegex(item)
    let unexpected = matchstr(a:item['text'], "unexpected '[^']\\+'")
    if len(unexpected) < 1
        return ''
    endif
    return '\V'.split(unexpected, "'")[1]
endfunction

function! SyntaxCheckers_php_GetLocList()
    let makeprg = "php -l -d error_reporting=E_ALL -d display_errors=1 -d log_errors=0 ".shellescape(expand('%'))
    let errorformat='%-GNo syntax errors detected in%.%#,Parse error: %#syntax %trror\ , %m in %f on line %l,Parse %trror: %m in %f on line %l,Fatal %trror: %m in %f on line %l,%-G\s%#,%-GErrors parsing %.%#'
    let errors = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

    if empty(errors)
        if !g:syntastic_phpcs_disable
            let errors = errors + s:GetPHPCSErrors()
        endif

        if !g:syntastic_phpmd_disable
            let errors = errors + s:GetPHPMDErrors()
        endif
    end

    return errors
endfunction

function! s:GetPHPCSErrors()
    let makeprg = "phpcs " . g:syntastic_phpcs_conf . " --report=csv ".shellescape(expand('%'))
    let errorformat = '%-GFile\,Line\,Column\,Type\,Message\,Source\,Severity,"%f"\,%l\,%c\,%t%*[a-zA-Z]\,"%m"\,%*[a-zA-Z0-9_.-]\,%*[0-9]'
    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat, 'subtype': 'Style' })
endfunction

"Helper function. This one runs and parses phpmd tool output.
function! s:GetPHPMDErrors()
    let makeprg = "phpmd " . shellescape(expand('%')) . " text " . g:syntastic_phpmd_rules
    let errorformat = '%E%f:%l%m'
    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat, 'subtype' : 'Style' })
endfunction
