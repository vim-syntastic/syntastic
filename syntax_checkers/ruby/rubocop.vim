"============================================================================
"File:        rubocop.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Recai Oktaş <roktas@bil.omu.edu.tr>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
"
" In order to use rubocop with the default ruby checker (mri):
"     let g:syntastic_ruby_checkers = ['mri', 'rubocop']

if exists("g:loaded_syntastic_ruby_rubocop_checker")
    finish
endif
let g:loaded_syntastic_ruby_rubocop_checker=1

function! SyntaxCheckers_ruby_rubocop_IsAvailable() dict
    let exe = self.getExec()
    return
        \ executable(exe) &&
        \ syntastic#util#versionIsAtLeast(syntastic#util#getVersion(exe . ' --version'), [0,9,0])
endfunction

function! SyntaxCheckers_ruby_rubocop_GetLocList() dict
    let makeprg = self.makeprgBuild({ 'args': '--format emacs --silent' })

    let errorformat = '%f:%l:%c: %t: %m'

    let loclist = SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'subtype': 'Style'})

    " convert rubocop severities to error types recognized by syntastic
    for e in loclist
        if e['type'] ==# 'F'
            let e['type'] = 'E'
        elseif e['type'] !=# 'W' && e['type'] !=# 'E'
            let e['type'] = 'W'
        endif
    endfor

    return loclist
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'ruby',
    \ 'name': 'rubocop'})
