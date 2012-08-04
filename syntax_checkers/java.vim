"============================================================================
"File:        java.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainers: Jochen Keil <jochen.keil at gmail dot com>
"             Nick Wertzberger <wertnick at the same>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
function! SyntaxCheckers_java_GetLocList()

    if exists('g:syntastic_mvn_pom')
        let errorformat = '[ERROR] %f:[%l\,%c]\ %m'
        let makeprg = 'mvn test -o '
                    \. ' -Dcompile.fork=true '
                    \. ' -Dmaven.junit.fork=true '
                    \. ' 2>&1 ' 
                    \. '\| sed -e "s\|[a-zA-Z0-9_./-]*'
                    \. expand ( '%:t' )
                    \. '\|'
                    \. expand ( '%:p:h' ) . '/' . expand ( '%:t' )
                    \. '\|"'

    else
        let makeprg = 'javac -Xlint '
                    \. expand ( '%:p:h' ) . '/' . expand ( '%:t' )
                    \. ' 2>&1 '
                    \. '\| sed -e "s\|[a-zA-Z0-9_./-]*'
                    \. expand ( '%:t' )
                    \. '\|'
                    \. expand ( '%:p:h' ) . '/' . expand ( '%:t' )
                    \. '\|"'

        " unashamedly stolen from *errorformat-javac* (quickfix.txt)
        let errorformat = '%A%f:%l:\ %m,%+Z%p^,%+C%.%#,%-G%.%#'
    endif

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

endfunction
