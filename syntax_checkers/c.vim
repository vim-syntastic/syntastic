"============================================================================
"File:        c.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if !exists('g:syntastic_c_checker')
    let g:syntastic_c_checker = "gcc"
endif

if g:syntastic_c_checker == "gcc"
    if executable("gcc")
        runtime! syntax_checkers/c/gcc.vim
    endif
elseif g:syntastic_c_checker == "checkpatch"
    if executable("checkpatch.pl") || executable("./scripts/checkpatch.pl")
        runtime! syntax_checkers/c/checkpatch.vim
    endif
elseif g:syntastic_c_checker == "checkpatch-kernel-only"
    if executable("./scripts/checkpatch.pl")
        runtime! syntax_checkers/c/checkpatch.vim
    elseif executable("gcc")
        runtime! syntax_checkers/c/gcc.vim
    endif
elseif g:syntastic_c_checker == "sparse"
    if executable("cgcc")
        runtime! syntax_checkers/c/sparse.vim
    endif
endif
