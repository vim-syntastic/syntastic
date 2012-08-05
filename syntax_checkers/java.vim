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

" gets back either classes or testclasses
function! SyntaxCheckers_java_getTargetDir(baseDir, dir)
    let targetDir = finddir ( a:dir , a:baseDir . '/' . g:syntastic_mvn_target . '**6')

    if filewritable ( targetDir ) != 2
        let targetDir = a:baseDir . '/' . g:syntastic_mvn_target . '/'. a:dir
        call mkdir(targetDir, 'p')
    endif
    
    let targetDir = fnamemodify(targetDir, '%:p')

    return targetDir
endfunction

function! SyntaxCheckers_java_GetLocList()

    let basepom = findfile('pom.xml', expand('%:p:h') . ';')

    if ! empty( basepom )

        " See if this is a web project or something odd.
        let classdir = (match(expand('%:p'),'.*src.test.*') ? 'classes' : 'test-classes')
        let otherclassdir = (match(expand('%:p'),'.*src.test.*') ? 'test-classes' : 'classes')

        let baseDir = fnamemodify(basepom, ':p:h') 
        let target = SyntaxCheckers_java_getTargetDir(baseDir, classdir)
        let othertarget = SyntaxCheckers_java_getTargetDir(baseDir, otherclassdir)

        let classpathFile = baseDir . '/.syntastic_classpath'

        " Step 1: generate classpath, if needed
        " NOTE: Maven will take at least 4 seconds to run.
        if (getftime(classpathFile) < getftime(basepom))
            call system('mvn -o -f '. shellescape(basepom)
                \. ' -Dmdep.outputFile=' . shellescape(classpathFile)
                \. ' dependency:build-classpath' )
        endif

        let classpath = readfile(classpathFile)[0] 
                \. ':' . target 
                \. ':' . othertarget

        " compile
        let makeprg = 'javac -Xlint -d ' . target
                    \. ' -cp ' . classpath . ' '
                    \. expand ( '%:p' )
                    \. ' 2>&1 '


    else
        let makeprg = 'javac -Xlint ' . expand('%:p') . ' 2>&1 '

    endif
    " unashamedly stolen from *errorformat-javac* (quickfix.txt)
    let errorformat = '%A%f:%l:\ %m,%+Z%p^,%+C%.%#,%-G%.%#'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

endfunction
