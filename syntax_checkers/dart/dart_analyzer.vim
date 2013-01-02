"============================================================================
"File:        dart_analyzer.vim
"Description: Dart syntax checker - using dart_analyzer
"Maintainer:  Maksim Ryzhikov <rv.maksim at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"============================================================================
if !exists("g:syntastic_dart_analyzer_conf")
    let g:syntastic_dart_analyzer_conf = ''
endif

function! SyntaxCheckers_dart_GetLocList()
    let args = !empty(g:syntastic_dart_analyzer_conf) ? ' ' . g:syntastic_dart_analyzer_conf : ''
    let makeprg = 'dart_analyzer ' . shellescape(expand("%")) . args

    let errorformat = '%Efile:%f:%l:%c: %m'
    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction
