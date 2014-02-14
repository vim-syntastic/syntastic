if exists("g:loaded_syntastic_erlang_syntaxerl_checker")
    finish
endif

let g:loaded_syntastic_erlang_syntaxerl_checker = 1

let s:save_cpo = &cpo
set cpo&vim


function! SyntaxCheckers_erlang_syntaxerl_GetLocList() dict

    let makeprg = self.makeprgBuild({})

    let errorformat =
            \ '%W%f:%l: warning: %m,'.
            \ '%E%f:%l: %m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'erlang',
    \ 'name': 'syntaxerl'})

let &cpo = s:save_cpo
unlet s:save_cpo
