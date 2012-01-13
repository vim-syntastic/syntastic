"============================================================================
"File:        locaml.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Török Edwin <edwintorok at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists("loaded_locaml_syntax_checker")
    finish
endif
let loaded_locaml_syntax_checker = 1

"bail if the user doesnt have camlp4o installed
if !executable("camlp4o")
    finish
endif

runtime syntax_checkers/ocaml.vim

function! SyntaxCheckers_locaml_GetLocList()
    return SyntaxCheckers_ocaml_GetLocList()
endfunction
