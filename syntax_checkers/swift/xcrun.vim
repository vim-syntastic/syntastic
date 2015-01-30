"============================================================================
"File:        xcrun.vim
"Description: swift syntax checker - using xcrun
"Maintainer:  Tom Fogg <tom@canobe.com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"============================================================================

if exists("g:loaded_syntastic_swift_xcrun_checker")
    finish
endif
let g:loaded_syntastic_xcrun_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_swift_xcrun_GetLocList() dict

    let makeprg = self.makeprgBuild({ 'args_after': 'swift' })

    let errorformat=
			\ '%f:%l:%c:{%*[^}]}:\ error:\ %m,'.
			\ '%f:%l:%c:{%*[^}]}:\ fatal\ error:\ %m,'.
			\ '%f:%l:%c:{%*[^}]}:\ warning:\ %m,'.
			\ '%f:%l:%c:\ error:\ %m,'.
			\ '%f:%l:%c:\ fatal\ error:\ %m,'.
			\ '%f:%l:%c:\ warning:\ %m,'.
			\ '%f:%l:\ Error:\ %m,'.
			\ '%f:%l:\ error:\ %m,'.
			\ '%f:%l:\ fatal\ error:\ %m,'.
			\ 'xcrun:\ %m,'.
			\ '%f:%l:\ warning:\ %m'

    let e = SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat })
    return e
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'swift',
    \ 'name': 'xcrun'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sts=4 sw=4:
