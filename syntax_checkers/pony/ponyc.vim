"============================================================================
"File:        ponyc.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Earnestly
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law.
"
"============================================================================

if exists('g:loaded_syntastic_pony_ponyc_checker')
    finish
endif
let g:loaded_syntastic_pony_ponyc_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_pony_ponyc_GetLocList() dict

    " This is currently a hack.  `ponyc` itself uses the project directory as
    " the target to build.  Using expand like this fetches the parent
    " directory of the current file which might cause supurious errors on
    " package imports if the current file is nested under a sub-directory.
    let n = expand('%:p:h')

    " NOTE: The `-p /usr/lib/pony` flag is a downstream (Arch Linux) change
    " which installs the standard packages to this location.  This should be
    " fixed upstream soon: <https://github.com/CausalityLtd/ponyc/issues/172>
    let makeprg = self.makeprgBuild({
                \ 'args': '-p /usr/lib/pony --pass=expr',
                \ 'fname': n})

    let errorformat =
                \ '%f:%l:%c: %m'

    return SyntasticMake({
                \ 'makeprg': makeprg,
                \ 'errorformat': errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
            \ 'filetype': 'pony',
            \ 'name': 'ponyc'})

let &cpo = s:save_cpo
unlet s:save_cpo
