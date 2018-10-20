if exists('g:loaded_syntastic_zig_zig_checker')
    finish
endif
let g:loaded_syntastic_zig_zig_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_zig_zig_IsAvailable() dict
    return executable(self.getExec())
endfunction

function! SyntaxCheckers_zig_zig_GetLocList() dict
    let makeprg = self.makeprgBuild({
                \ 'exe_after': 'build', 
                \ 'fname': '' })
    let errorformat = '%f:%l:%c: %m'
    let loclist = SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'env': {} })
    return loclist
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
            \ 'filetype': 'zig',
            \ 'name':     'zig' })

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
