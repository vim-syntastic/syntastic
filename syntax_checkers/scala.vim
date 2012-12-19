"============================================================================
"File:        scala.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Rickey Visinski <rickeyvisinski at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

"bail if the user doesnt have the scala binary installed
if !executable("scala")
    finish
endif

if !exists("g:syntastic_scala_options")
    let g:syntastic_scala_options = " "
endif

function! SyntaxCheckers_scala_GetLocList()
    let makeprg = 'scala '. g:syntastic_scala_options .' '.  shellescape(expand('%')) . ' /dev/null'

    let errorformat = '%f\:%l: %trror: %m'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction

