"============================================================================
"File:        swiffer.vim
"Description: Dust.js syntax checker - using swiffer
"Maintainer:  Steven Foote <smfoote at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"============================================================================

if exists("g:loaded_syntastic_dustjs_swiffer_checker")
    finish
endif

let g:loaded_syntastic_dustjs_swiffer_checker = 1

function! SyntaxCheckers_dustjs_swiffer_IsAvailable()
    return executable("swiffer")
endfunction

function! SyntaxCheckers_dustjs_swiffer_GetLocList()
      let makeprg = syntastic#makeprg#build({
                  \ 'exe': 'swiffer',
                  \ 'subchecker': 'swiffer',
                  \ 'filetype': 'dustjs' })
      let errorformat = '%E%f - Line %l\, Column %c: %m'
      let loclist = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

      return loclist
 endfunction

call SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'dustjs',
    \ 'name': 'swiffer'})
