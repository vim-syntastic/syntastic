"============================================================================
"File:        validator.vim
"Description: Syntax checking plugin for syntastic
"Maintainer:  LCD 47 <lcd047 at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists('g:loaded_syntastic_xhtml_validator_checker')
    finish
endif
let g:loaded_syntastic_xhtml_validator_checker=1

if !exists('g:syntastic_xhtml_validator_api')
    let g:syntastic_xhtml_validator_api = 'https://validator.nu/'
endif

if !exists('g:syntastic_xhtml_validator_parser')
    let g:syntastic_xhtml_validator_parser = ''
endif

if !exists('g:syntastic_xhtml_validator_nsfilter')
    let g:syntastic_xhtml_validator_nsfilter = ''
endif

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_xhtml_validator_GetLocList() dict
    return SyntaxCheckers_html_validator_GetLocListForType(self.getExecEscaped(), 'xhtml')
endfunction

runtime! syntax_checkers/html/validator.vim

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'xhtml',
    \ 'name': 'validator',
    \ 'exec': 'curl' })

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
