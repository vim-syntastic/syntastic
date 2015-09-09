"============================================================================
"File:        shellcheck.vim
"Description: Shell script syntax/style checking plugin for syntastic.vim
"============================================================================

if exists('g:loaded_syntastic_sh_shellcheck_checker')
    finish
endif
let g:loaded_syntastic_sh_shellcheck_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_sh_shellcheck_GetLocList() dict
    let args_after = '-f gcc --shell ' . get(g:, 'syntastic_shellcheck_checker_shell', 'sh')
    let makeprg = self.makeprgBuild({ 'args_after': args_after })

    let errorformat =
        \ '%f:%l:%c: %trror: %m,' .
        \ '%f:%l:%c: %tarning: %m,' .
        \ '%f:%l:%c: %tote: %m'

    let loclist = SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'returns': [0, 1] })

    for e in loclist
        if e['type'] ==? 'n'
            let e['type'] = 'w'
            let e['subtype'] = 'Style'
        endif
    endfor

    return loclist
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'sh',
    \ 'name': 'shellcheck' })

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
