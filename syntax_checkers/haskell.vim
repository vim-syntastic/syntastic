"============================================================================
"File:        haskell.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Anthony Carapetis <anthony.carapetis at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if !exists('g:syntastic_haskell_checker')
    if executable('hdevtools')
        runtime! syntax_checkers/haskell/hdevtools.vim
    elseif executable('ghc-mod')
        runtime! syntax_checkers/haskell/ghc-mod.vim
    endif
elseif g:syntastic_haskell_checker == 'hdevtools'
    if executable('hdevtools')
        runtime! syntax_checkers/haskell/hdevtools.vim
    endif
elseif g:syntastic_haskell_checker == 'ghc-mod'
    if executable('ghc-mod')
        runtime! syntax_checkers/haskell/ghc-mod.vim
    endif
endif
