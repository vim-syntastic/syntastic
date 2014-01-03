"============================================================================
"File:        jslint.vim
"Description: Javascript syntax checker - using jslint
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"             adapted by Harry Percival (hjwp2@cantab.net) to lint js in html
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"NB - requires jslint <= 0.1.11. versions 0.2+ dropped support for linting
"                                js inside html
"============================================================================
if exists("g:loaded_syntastic_html_jslint_checker")
    finish
endif
let g:loaded_syntastic_html_jslint_checker=1

function! SyntaxCheckers_html_jslint_GetHighlightRegex(item)
    let term = matchstr(a:item['text'], '\mExpected .* and instead saw ''\zs.*\ze''')
    if term != ''
        let term = '\V' . term
    endif
    return term
endfunction

function! SyntaxCheckers_html_jslint_GetLocList() dict
    let makeprg = self.makeprgBuild({ 'args': '--white --nomen --regexp --plusplus --bitwise --newcap --sloppy --vars' })

    let errorformat =
        \ '%E %##%\d%\+ %m,'.
        \ '%-Z%.%#Line %l\, Pos %c,'.
        \ '%-G%.%#'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'defaults': {'bufnr': bufnr("")} })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'html',
    \ 'name': 'jslint'})

