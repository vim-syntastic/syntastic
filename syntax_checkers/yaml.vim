"============================================================================
"File:        yaml.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"
"Installation: $ npm install -g js-yaml
"
"============================================================================

if !executable("js-yaml")
    finish
endif

function! SyntaxCheckers_yaml_GetLocList()
    let makeprg='js-yaml --compact ' . shellescape(expand('%'))
    let errorformat='Error on line %l\, col %c:%m,%-G%.%#'
    return SyntasticMake({ 'makeprg': makeprg,
                         \ 'errorformat': errorformat,
                         \ 'defaults': {'bufnr': bufnr("")} })
endfunction
