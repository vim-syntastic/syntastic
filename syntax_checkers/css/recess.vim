"============================================================================
"File:        css.vim
"Description: Syntax checking plugin for syntastic.vim using `recess` CLI tool (http://twitter.github.io/recess/).
"Maintainer:  Tim Carry <tim at pixelastic dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"============================================================================
"
" Specify additional options to recess with this option. e.g. to disable
" warnings:
"
"   let g:syntastic_recess_options = '--noIDs false'

if exists('g:loaded_syntastic_css_recess_checker')
    finish
endif
let g:loaded_syntastic_css_recess_checker=1

if !exists('g:syntastic_recess_options')
    let g:syntastic_recess_options = ''
endif

function! SyntaxCheckers_css_recess_GetLocList() dict
    let makeprg = self.makeprgBuild({ 'args': '--format=compact --stripColors ' . g:syntastic_recess_options })

     let errorformat = ''


    " Multiline parse error :
    " -----
    " Parser error in buttons.css
    " 
    "       34.   background: #333333;
    "       35.   unknown-property: foo();
    "       36.   color: red;
    " -----
    let errorformat .= '%E%m in %f,'
    let errorformat .= '%Z %#%l.%.%#,'

    " Single line error messages
    " -----
    " forms.css:9:No need to specify units when a value is 0
    " -----
    let errorformat .= '%f:%l:%m,'
    
    " We won't keep anything else
    let errorformat .= '%-G%.%#'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'defaults': {'bufnr': bufnr("")} })

endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'css',
    \ 'name': 'recess'})
