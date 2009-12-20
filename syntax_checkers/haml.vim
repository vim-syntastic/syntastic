"============================================================================
"File:        haml.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists("loaded_haml_syntax_checker")
    finish
endif
let loaded_haml_syntax_checker = 1

"bail if the user doesnt have the haml binary installed
if !executable("haml")
    finish
endif

function! SyntaxCheckers_haml_GetLocList()
    let output = system("haml -c " . shellescape(expand("%")))
    if v:shell_error != 0
        "haml only outputs the first error, so parse it ourselves
        let line = substitute(output, '^Syntax error on line \(\d*\):.*', '\1', '')
        let msg = substitute(output, '^Syntax error on line \d*:\(.*\)', '\1', '')
        return [{'lnum' : line, 'text' : msg, 'bufnr': bufnr(""), 'type': 'E' }]
    endif
    return []
endfunction
