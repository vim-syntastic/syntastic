"============================================================================
"File:        phpmd.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
"
" See here for details of phpmd
"   - phpmd (see http://phpmd.org)

function! SyntaxCheckers_php_phpmd_IsAvailable()
    return executable('phpmd')
endfunction

function! SyntaxCheckers_php_phpmd_GetLocList()
    let makeprg = syntastic#makeprg#build({
                \ 'exe': 'phpmd',
                \ 'post_args': 'text  codesize,design,unusedcode,naming',
                \ 'subchecker': 'phpmd' })
    let errorformat = '%E%f:%l%m'
    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat, 'subtype' : 'Style' })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'php',
    \ 'name': 'phpmd'})
