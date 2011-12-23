"============================================================================
"File:        jslint.vim
"Description: Javascript syntax checker - using jslint
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"============================================================================
if !exists("g:syntastic_javascript_jslint_conf")
    let g:syntastic_javascript_jslint_conf = "--good"
endif

function! SyntaxCheckers_javascript_HighlightTerm(error)
    let unexpected = matchstr(a:error['text'], 'Expected.*and instead saw \'\zs.*\ze\'')
    if len(unexpected) < 1 | return '' | end
    return '\V'.split(unexpected, "'")[1]
endfunction

function! SyntaxCheckers_javascript_GetLocList()
    let makeprg = "jslint " . g:syntastic_javascript_jslint_conf . " " . shellescape(expand('%'))
    let errorformat='%E %##%n %m,%-Z%.%#Line %l\, Pos %c,%-G%.%#'
    let errors = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat, 'defaults': {'bufnr': bufnr("")} })
    call filter(errors, "v:val['text'] != \"Missing 'use strict' statement.\"")

    call SyntasticHighlightErrors(errors, function('SyntaxCheckers_javascript_HighlightTerm'))

    return errors
endfunction

