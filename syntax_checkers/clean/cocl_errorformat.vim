"============================================================================
"File:        cocl_errorformat.vim
"Description: Error formats of the Clean compiler (cocl) for syntastic.vim
"Maintainer:  Camil Staps <info at camilstaps dot nl>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

" (Mainly) from timjs/clean-vim
let g:syntastic_clean_cocl_errorformat  = '%E%trror [%f\,%l]: %m' " General error (without location info)
let g:syntastic_clean_cocl_errorformat .= ',%E%trror [%f\,%l\,]: %m' " General error (without location info)
let g:syntastic_clean_cocl_errorformat .= ',%E%trror [%f\,%l\,%s]: %m' " General error
let g:syntastic_clean_cocl_errorformat .= ',%E%type error [%f\,%l\,%s]:%m' " Type error
let g:syntastic_clean_cocl_errorformat .= ',%E%tverloading error [%f\,%l\,%s]:%m' " Overloading error
let g:syntastic_clean_cocl_errorformat .= ',%E%tniqueness error [%f\,%l\,%s]:%m' " Uniqueness error
let g:syntastic_clean_cocl_errorformat .= ',%E%tarse error [%f\,%l;%c\,%s]: %m' " Parse error
let g:syntastic_clean_cocl_errorformat .= ',%+C %m' " Extra info
let g:syntastic_clean_cocl_errorformat .= ',%-G%s' " Ignore rest

" vim: set sw=4 sts=4 et fdm=marker:
