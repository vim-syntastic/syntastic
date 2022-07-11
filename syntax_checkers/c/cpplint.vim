"============================================================================
"File:        cpplint.vim
"Description: Syntax checking plugin for syntastic
"Maintainer:  LCD 47 <lcd047 at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists('g:loaded_syntastic_c_cpplint_checker')
    finish
endif
let g:loaded_syntastic_c_cpplint_checker = 1

if !exists('g:syntastic_c_cpplint_thres')
    let g:syntastic_c_cpplint_thres = 5
endif

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'c',
    \ 'name': 'cpplint',
    \ 'redirect': 'cpp/cpplint'})

" vim: set sw=4 sts=4 et fdm=marker:
