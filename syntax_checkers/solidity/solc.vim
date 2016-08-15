"============================================================================
"File:        solc.vim
"Description: Solidity syntax checker - using solc
"Maintainer:  Jacob Cholewa <jacob@cholewa.dk>
"============================================================================

if exists('g:loaded_syntastic_solidity_solc_checker')
	finish
endif
let g:loaded_syntastic_solidity_solc_checker = 1


let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_solidity_solc_GetLocList() dict
	let makeprg = self.makeprgBuild({})

	let errorformat = '%f:%l:%c: Error: %m'

	return SyntasticMake({
		\ 'makeprg': makeprg,
		\ 'errorformat': errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
		\ 'filetype': 'solidity',
		\ 'name': 'solc' })

let &cpo = s:save_cpo
unlet s:save_cpo
