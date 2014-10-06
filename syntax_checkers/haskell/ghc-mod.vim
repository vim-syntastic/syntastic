"============================================================================
"File:        ghc-mod.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Anthony Carapetis <anthony.carapetis at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists('g:loaded_syntastic_haskell_ghc_mod_checker')
    finish
endif
let g:loaded_syntastic_haskell_ghc_mod_checker = 1

let s:ghc_mod_new = -1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_haskell_ghc_mod_IsAvailable() dict
    if !executable(self.getExec())
        return 0
    endif

    " We need either a Vim version that can handle NULs in system() output,
    " or a ghc-mod version that has the "--boundary" option.
    try
        let ver = filter(split(system(self.getExecEscaped()), '\n'), 'v:val =~# ''\m^ghc-mod version''')[0]
        let parsed_ver = syntastic#util#parseVersion(ver)
        call self.log(self.getExec() . ' version =', parsed_ver)
        let s:ghc_mod_new = syntastic#util#versionIsAtLeast(parsed_ver, [2, 1, 2])
    catch /\m^Vim\%((\a\+)\)\=:E684/
        call syntastic#log#error("checker haskell/ghc_mod: can't parse version string (abnormal termination?)")
        let s:ghc_mod_new = -1
    endtry

    return (s:ghc_mod_new >= 0) && (v:version >= 704 || s:ghc_mod_new)
endfunction

function! SyntaxCheckers_haskell_ghc_mod_GetLocList() dict
    let makeprg = self.makeprgBuild({
        \ 'exe': self.getExecEscaped() . ' check' . (s:ghc_mod_new ? ' --boundary=""' : '') })

    let errorformat =
        \ '%-G%\s%#,' .
        \ '%f:%l:%c:%trror: %m,' .
        \ '%f:%l:%c:%tarning: %m,'.
        \ '%f:%l:%c: %trror: %m,' .
        \ '%f:%l:%c: %tarning: %m,' .
        \ '%f:%l:%c:%m,' .
        \ '%E%f:%l:%c:,' .
        \ '%Z%m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'postprocess': ['compressWhitespace'],
        \ 'returns': [0] })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'haskell',
    \ 'name': 'ghc_mod',
    \ 'exec': 'ghc-mod' })

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sts=4 sw=4:
