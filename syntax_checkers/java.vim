"============================================================================
"File:        java.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Jochen Keil <jochen.keil at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
function! SyntaxCheckers_java_GetLocList()

    let makeprg = 'javac -Xlint '
               \. expand ( '%:p:h' ) . '/' . expand ( '%:t' )
               \. ' 2>&1 \| '
               \. 'sed -e "s\|'
               \. expand ( '%:t' )
               \. '\|'
               \. expand ( '%:p:h' ) . '/' . expand ( '%:t' )
               \. '\|"'

    " unashamedly stolen from *errorformat-javac* (quickfix.txt)
    let errorformat = '%A%f:%l:\ %m,%+Z%p^,%+C%.%#,%-G%.%#'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

endfunction
