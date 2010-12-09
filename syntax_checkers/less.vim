"============================================================================
"File:        less.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Julien Blanchard <julien at sideburns dot eu>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists("loaded_less_syntax_checker")
    finish
endif
let loaded_less_syntax_checker = 1

"bail if the user doesnt have the lessc binary installed
if !executable("lessc")
    finish
endif

function! SyntaxCheckers_less_GetLocList()
    let output = system("lessc " . shellescape(expand("%")))
    if v:shell_error != 0
        "less only outputs the first error, so parse it ourselves
        let line = substitute(output, '^! Syntax Error: on line \(\d*\):.*$', '\1', '')
        let msg = substitute(output, '^! Syntax Error: on line \d*:\(.*\)$', '\1', '')
        return [{'lnum' : line, 'text' : msg, 'bufnr': bufnr(""), 'type': 'E' }]
    endif
    return []
endfunction

