"============================================================================
"File:        lisp.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Karl Yngve Lervåg <karl.yngve@lervag.net>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists("g:loaded_syntastic_lisp_clisp_checker")
    finish
endif
let g:loaded_syntastic_lisp_clisp_checker=1

function! SyntaxCheckers_lisp_clisp_IsAvailable()
    return executable("clisp")
endfunction

function! SyntaxCheckers_lisp_clisp_GetLocList()
    let makeprg = syntastic#makeprg#build({
                \ 'exe': 'clisp',
                \ 'args': '-q -c',
                \ 'tail': '-o /tmp/clisp-vim-compiled-file',
                \ 'subchecker': 'clisp' })

    let efm  = '%-G;%.%#,'

    let efm .= '%W%>WARNING:%.%#line %l : %m,'
    let efm .= '%Z  %#%m,'

    let efm .= '%W%>WARNING:%.%#lines %l..%\d\# : %m,'
    let efm .= '%Z  %#%m,'

    let efm .= '%E%>The following functions were %m,'
    let efm .= '%Z %m,'

    let efm .= '%-G%.%#'
    return SyntasticMake({ 'makeprg': makeprg,
                         \ 'errorformat': efm,
                         \ 'defaults': {'bufnr': bufnr('')} })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'lisp',
    \ 'name': 'clisp'})
