"============================================================================
"File:        phpcs.vim
"Description: JavaScript syntax checker, using `phpcs`.
"Maintainer:  Jackson Cooper <jackson at jacksonc dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists('g:loaded_syntastic_javascript_phpcs_checker')
    finish
endif
let g:loaded_syntastic_javascript_phpcs_checker = 1

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'javascript',
    \ 'name': 'phpcs',
    \ 'redirect': 'php/phpcs'})

" vim: set sw=4 sts=4 et fdm=marker:
