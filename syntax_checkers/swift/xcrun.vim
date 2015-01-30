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
