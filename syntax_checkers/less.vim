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

" To send additional options to less use the variable g:syntastic_less_options.
" The default is
"   let g:syntastic_less_options = "--no-color"
"
" To use less-lint instead of less set the variable
" g:syntastic_less_use_less_lint.

if exists("loaded_less_syntax_checker")
    finish
endif
let loaded_less_syntax_checker = 1

"bail if the user doesnt have the lessc binary installed
if !executable("lessc")
    finish
endif

if !exists("g:syntastic_less_options")
    let g:syntastic_less_options = "--no-color"
endif

if !exists("g:syntastic_less_use_less_lint") || g:syntastic_less_use_less_lint == 0
    let s:check_file = 'lessc'
else
    let s:check_file = 'node ' . expand('<sfile>:p:h') . '/less-lint.js'
end

function! SyntaxCheckers_less_GetLocList()
    let makeprg = s:check_file . ' ' . g:syntastic_less_options . ' ' .
                \ shellescape(expand('%')) . ' /dev/null'

    "lessc >= 1.2
    let errorformat = '%m in %f:%l:%c'
    "lessc < 1.2
    let errorformat .= ', Syntax %trror on line %l in %f,Syntax %trror on line %l,! Syntax %trror: on line %l: %m,%-G%.%#'

    return SyntasticMake({ 'makeprg': makeprg,
                         \ 'errorformat': errorformat,
                         \ 'defaults': {'bufnr': bufnr(""), 'text': "Syntax error"} })
endfunction

