"============================================================================
"File:        cs.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Daniel Walker <dwalker@fifo99.com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if !executable('mcs')
    finish
endif

function! SyntaxCheckers_cs_GetLocList()
    let makeprg = "mcs --parse ".shellescape(expand('%'))
    let errorformat = '%f(%l\,%c): %trror %m'
    let loclist = SyntasticMake({ 'makeprg': makeprg,
                                \ 'errorformat': errorformat,
                                \ 'defaults': {'bufnr': bufnr("")} })
    return loclist
endfunction

