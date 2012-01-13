"============================================================================
"File:        ocaml.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Török Edwin <edwintorok at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists("loaded_ocaml_syntax_checker")
    finish
endif
let loaded_ocaml_syntax_checker = 1

"bail if the user doesnt have camlp4o installed
if !executable("camlp4o")
    finish
endif

function! SyntaxCheckers_ocaml_GetLocList()
    let extension = expand('%:e')
    if match(extension, 'mly') >= 0
        " ocamlyacc output can't be redirected, so use menhir
        if !executable("menhir")
            return []
        endif
        let makeprg = "menhir --only-preprocess ".shellescape(expand('%')) . " >/dev/null"
    elseif match(extension,'mll') >= 0
        if !executable("ocamllex")
            return []
        endif
        let makeprg = "ocamllex -q -o /dev/null ".shellescape(expand('%'))
    else
        let makeprg = "camlp4o -o /dev/null ".shellescape(expand('%'))
    endif
    let errorformat = '%EFile "%f"\, line %l\, characters %c-%*\d:,'.
                \ '%EFile "%f"\, line %l\, characters %c-%*\d (end at line %*\d\, character %*\d):,'.
                \ '%EFile "%f"\, line %l\, character %c:,'.
                \ '%EFile "%f"\, line %l\, character %c:%m,'.
                \ '%C%m'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction
