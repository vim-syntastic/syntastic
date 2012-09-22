"============================================================================
"File:        eruby.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists("loaded_eruby_syntax_checker")
    finish
endif
let loaded_eruby_syntax_checker = 1

"bail if the user doesnt have ruby installed
if !executable("ruby")
    finish
endif

function! SyntaxCheckers_eruby_GetLocList()
    "gsub fixes issue #7 rails has it's own eruby syntax
    if has('win32')
        let makeprg='ruby -rerb -e "puts ERB.new(File.read(''' .
            \ (expand("%")) .
            \ ''').gsub(''<\%='',''<\%''), nil, ''-'').src" \| ruby -c'
    else
        let makeprg='RUBYOPT= ruby -rerb -e "puts ERB.new(File.read(''' .
            \ (expand("%")) .
            \ ''').gsub(''<\%='',''<\%''), nil, ''-'').src" \| RUBYOPT= ruby -c'
    endif

    let errorformat='%-GSyntax OK,%E-:%l: syntax error\, %m,%Z%p^,%W-:%l: warning: %m,%Z%p^,%-C%.%#'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat})
endfunction
