"============================================================================
"File:        sweet.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Rick Veens <rickveens92 at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists('g:loaded_syntastic_alf_sweet_checker')
    finish
endif
let g:loaded_syntastic_alf_sweet_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_alf_sweet_IsAvailable() dict
    if !exists('g:syntastic_alf_compiler')
        let g:syntastic_alf_compiler = self.getExec()
    endif
    call self.log('g:syntastic_alf_compiler =', g:syntastic_alf_compiler)
    return executable(expand(g:syntastic_alf_compiler, 1))
endfunction

function! SyntaxCheckers_alf_sweet_GetLocList() dict
	" example: sweet -i=filename.alf 
	" there must be no spaces between -i= and the filename string
	let makeprg = self.makeprgBuild({
				\ 'exe': self.getExec(),
                \ "fname": "-i=" . shellescape(expand("%", 1)) })

	" Example SWEET output error:
	"
	"SWEET version Unversioned directory (?)
	"Executing command 'input-files'.
	"At 2.4-2.19:
	"
	" { least_addr_unit 8 }
	"   ~~~~~~~~~~~~~~~
	"
	"syntax error, unexpected least_addr_unit, expecting macro_defs.
	"Program aborted: Error during execution of command 'input-files': Error while parsing ALF code.

	" Note: I used https://flukus.github.io/2015/07/03/2015_07_03-Vim-errorformat-Demystified/
	" as a guide writing this.
    let errorformat =
        \ '%E%.%#SWEET\ version\ %.%#,' .
        \ '%C%.%#At\ %l.%c-%.%#,' .
        \ '%C%.%#syntax\ error\,\ %m%.%#,' .
        \ '%C%.%#'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'defaults': {'bufnr': bufnr('')} })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
            \ 'filetype': 'alf',
            \ 'name': 'sweet',
			\ 'exec': 'sweet'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
