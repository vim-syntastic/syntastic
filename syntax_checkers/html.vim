"============================================================================
"File:        html.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if !exists('g:syntastic_html_checker')
    let g:syntastic_html_checker = "tidy"
endif

if g:syntastic_html_checker == "tidy"
    if executable("tidy") && executable("grep")
        runtime! syntax_checkers/html/tidy.vim
    endif
elseif g:syntastic_html_checker == "w3"
    if executable("curl") && executable("sed")
        runtime! syntax_checkers/html/w3.vim
    endif
endif
