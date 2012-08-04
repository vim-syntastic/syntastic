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

    if exists('g:syntastic_mvn_target')
        let errorformat = '[ERROR] %f:[%l\,%c]\ %m'
        " Step 1: generate classpath, if needed
        " Step 2: compile
        " Step 3: kick off new build to update class files.
        let target = g:syntastic_mvn_target . ( match( expand ( '%:p' ) , '.*src.test.*' ) ? '/classes' : '/test-classes' )
        let makeprg = '[[ .javacpath -nt pom.xml ]] '
                    \. ' \|\| (mvn dependency:build-classpath 2>/dev/null '
                    \. ' \| grep -v "^\[INFO\]" \| xargs echo -n '
                    \. '&& echo -n :' 
                    \. g:syntastic_mvn_target . '/classes'
                    \. '&& echo -n :' 
                    \. g:syntastic_mvn_target . '/test-classes'
                    \. ') > .javacpath; '
                    \. ' [[ -e pom.xml ]] && mkdir -p '. target . '; '
                    \. ' [[ -e ' . target . ' ]] && '
                    \. 'javac -Xlint -d ' . target
                    \. ' -cp `cat .javacpath` '
                    \. expand ( '%:p' )
                    \. ' 2>&1 '
                    \. ' \| sed -e "s\|'
                    \. expand ( '%:t' )
                    \. '\|'
                    \. expand ( '%:p' )
                    \. '\|"'

    else
        let makeprg = 'javac -Xlint '
                    \. expand ( '%:p:h' ) . '/' . expand ( '%:t' )
                    \. ' 2>&1 '
                    \. '\| sed -e "s\|[a-zA-Z0-9_./-]*'
                    \. expand ( '%:t' )
                    \. '\|'
                    \. expand ( '%:p' )
                    \. '\|"'

    endif
    " unashamedly stolen from *errorformat-javac* (quickfix.txt)
    let errorformat = '%A%f:%l:\ %m,%+Z%p^,%+C%.%#,%-G%.%#'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

endfunction
