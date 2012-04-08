"============================================================================
"File:        checkpatch.vim
"Description: Syntax checking plugin for syntastic.vim using checkpatch.pl 
"Maintainer:  Daniel Walker <dwalker at fifo99 dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"============================================================================
if exists("loaded_checkpatch_syntax_checker")
    finish
endif
let loaded_checkpatch_syntax_checker = 1

" Bail if the user doesn't have `checkpatch.pl` installed.
if !executable("checkpatch.pl")
    finish
endif

command! Checkpatch call g:CacheStaticErrors("checkpatch")

function! SyntaxCheckers_checkpatch_GetLocList()
    let makeprg = "checkpatch.pl --no-summary --no-tree --terse --file ".shellescape(expand('%'))

    let errorformat = '%f:%l: %tARNING: %m,%f:%l: %tRROR: %m'

    let loclist = SyntasticMake({ 'makeprg': makeprg,
                                \ 'errorformat': errorformat,
                                \ 'defaults': {'bufnr': bufnr("")} })
    return loclist
endfunction
