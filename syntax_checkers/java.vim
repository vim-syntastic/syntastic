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

        let getrightdir =  'while [[ ! -e pom.xml && $PWD != "/" ]]; do cd ..; done;'
                        \. '[[ $PWD == "/" ]] && exit 1;'

        " See if this is a web project or something odd.
        let target = (match(expand('%:p'),'.*src.test.*') ? 'classes' : 'test-classes')
        let findtarget = '`find ' . g:syntastic_mvn_target 
                        \. ' -name ' . target . ' 2>/dev/null \| grep ' .target
                        \. ' \|\| echo ' . g:syntastic_mvn_target . '/' . target
                        \. '`'

        " This oculd be refactored.
        let othertarget = (match(expand('%:p'),'.*src.test.*') ? 'test-classes' : 'classes')
        let findothertarget = '`find ' . g:syntastic_mvn_target 
                        \. ' -name ' . othertarget . ' 2>/dev/null \| grep ' . othertarget
                        \. ' \|\| echo ' . g:syntastic_mvn_target . '/' . othertarget
                        \. '`'

        " Step 1: generate classpath, if needed
        " NOTE: Maven will take at least 4 seconds to run.
        let makedeps = '[[ .javacpath -nt pom.xml ]] '
                    \. ' \|\| (mvn dependency:build-classpath 2>/dev/null '
                    \. ' \| grep -v "^\[INFO\]" \| xargs echo -n '
                    \. ' && echo -n :' . findtarget
                    \. ' && echo -n :' . findothertarget
                    \. ' ) > .javacpath; '

        let maketarget = ' [[ -e pom.xml ]] && mkdir -p '. findtarget  . '; '

        " Step 2: compile
        let javacall = ' [[ -e ' . findtarget . ' ]] && '
                    \. 'javac -Xlint -d ' . findtarget
                    \. ' -cp `cat .javacpath` '
                    \. expand ( '%:p' )
                    \. ' 2>&1 '
                    \. ' \| sed -e "s\|'
                    \. expand ( '%:t' )
                    \. '\|'
                    \. expand ( '%:p' )
                    \. '\|"'

        let makeprg = getrightdir . makedeps . maketarget . javacall

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
