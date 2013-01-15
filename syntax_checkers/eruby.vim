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

if !exists("g:syntastic_ruby_exec")
    let g:syntastic_ruby_exec = "ruby"
endif

"bail if the user doesnt have ruby installed
if !executable(expand(g:syntastic_ruby_exec))
    finish
endif

function! SyntaxCheckers_eruby_GetLocList()
    let ruby_exec=expand(g:syntastic_ruby_exec)
    if !has('win32')
        let ruby_exec='RUBYOPT= ' . ruby_exec
    endif

    "gsub fixes issue #7 rails has it's own eruby syntax
    let makeprg=ruby_exec . ' -rerb -e "puts ERB.new(File.read(''' .
        \ (expand("%")) .
        \ ''').gsub(''<\%='',''<\%''), nil, ''-'').src" \| ' . ruby_exec . ' -c'

    let errorformat='%-GSyntax OK,%E-:%l: syntax error\, %m,%Z%p^,%W-:%l: warning: %m,%Z%p^,%-C%.%#'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat})
endfunction
