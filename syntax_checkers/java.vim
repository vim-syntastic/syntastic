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
    
    let targetDir = fnamemodify(targetDir, ':p')

    return targetDir
endfunction

function! SyntaxCheckers_java_GetLocList()

    " like 95% of the time, the target directory is just target.
    if !exists("g:syntastic_mvn_target")
        let g:syntastic_mvn_target = 'target'
    endif

    let basepom = findfile('pom.xml', expand('%:p:h') . ';')

    if ! empty( basepom )

        " We'll need to do this for both directories.
        let classdir = (match(expand('%:p'),'.*src.test.*') ? 'classes' : 'test-classes')
        let otherclassdir = (match(expand('%:p'),'.*src.test.*') ? 'test-classes' : 'classes')

        " generate all the relevant maven directories.
        let baseDir = fnamemodify(basepom, ':p:h') 
        let target = SyntaxCheckers_java_getTargetDir(baseDir, classdir)
        let othertarget = SyntaxCheckers_java_getTargetDir(baseDir, otherclassdir)

        " We cache the classpath in a file in the base directory.
        let classpathFile = baseDir . '/.syntastic_classpath'

        " Generate classpath if needed
        " NOTE: Maven will take at least 4 seconds to run. TRY TO AVOID THAT
        if (getftime(classpathFile) < getftime(basepom))
            call system('mvn -o -f '. shellescape(basepom)
                \. ' -Dmdep.outputFile=' . shellescape(classpathFile)
                \. ' dependency:build-classpath' )
        endif

        " Classpath = all the related jars + the different classpath
        let classpath = readfile(classpathFile)[0] 
                \. ':' . target 
                \. ':' . othertarget

        " Compile.
        let makeprg = 'javac -Xlint -d ' . target
                    \. ' -cp ' . classpath . ' '
                    \. expand('%:p') . ' 2>&1 '


    else
        " It's not maven. just go back to the old way.
        let makeprg = 'javac -Xlint ' . expand('%:p') . ' 2>&1 '

    endif
    " unashamedly stolen from *errorformat-javac* (quickfix.txt)
    let errorformat = '%A%f:%l:\ %m,%+Z%p^,%+C%.%#,%-G%.%#'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

endfunction
