"============================================================================
"File:        jshint-redirect.vim
"Description: Syntax checking plugin that uses jshint
"Maintainer:  LCD 47 <lcd047 at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"             
" requires g:syntastic_html_jshint_args="--extract=always" to be set in vimrc
"============================================================================

if exists("g:loaded_syntastic_html_jshint_checker")
    finish
endif
let g:loaded_syntastic_html_jshint_checker = 1

runtime! syntax_checkers/javascript/jshint.vim

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'html',
    \ 'name': 'jshint',
    \ 'redirect': 'javascript/jshint'})

