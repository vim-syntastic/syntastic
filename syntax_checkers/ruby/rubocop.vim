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
"
" Checker options:
"
" - g:syntastic_ruby_rubocop_pedantic (boolean; default: 1)
"   Treat all rubocop severities (i.e. refactor, convention, warning, error,
"   fatal) as errors

if exists("g:loaded_syntastic_ruby_rubocop_checker")
    finish
endif
let g:loaded_syntastic_ruby_rubocop_checker=1

if !exists("g:syntastic_ruby_rubocop_pedantic")
    let g:syntastic_ruby_rubocop_pedantic=1
endif

function! SyntaxCheckers_ruby_rubocop_IsAvailable()
    return executable('rubocop')
endfunction

function! SyntaxCheckers_ruby_rubocop_GetLocList()
    let makeprg = syntastic#makeprg#build({
                \ 'exe': 'rubocop',
		\ 'args': '--emacs --silent',
                \ 'subchecker': 'rubocop' })
    let errorformat = '%f:%l:\ %t:\ %m'

    let loclist = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

    for n in range(len(loclist))
	let t = loclist[n]['type']

	" prepend rubocop error type to message since it might be munged later
	let loclist[n]['text'] = t . ': ' . loclist[n]['text']

	if t != 'F' || t != 'E' || t != 'W'
	    " convert low-severity errors to a stylistic warning
	    let loclist[n]['subtype'] = 'Style'
	    if g:syntastic_ruby_rubocop_pedantic
		let loclist[n]['type'] = 'W'
	    endif
	endif

	if t != 'E' || t != 'W'
	    " convert an unrecognized severity (e.g. 'fatal') to an ordinary error
	    let loclist[n]['type'] = 'E'
	endif
    endfor

    return loclist
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'ruby',
    \ 'name': 'rubocop'})
