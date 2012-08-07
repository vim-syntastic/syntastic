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
    " like 95% of the time, the target directory is just 'target'.
    if !exists("g:syntastic_mvn_target")
        let g:syntastic_mvn_target = 'target'
    endif

    " This braks on paths with a space in them... :(
    " let targetDir = finddir (a:dir , a:baseDir . '/' . g:syntastic_mvn_target . '**6')

    let targetDir = a:baseDir . '/' . g:syntastic_mvn_target . '/'. a:dir

    if filewritable(targetDir) != 2
        call mkdir(targetDir, 'p')
    endif

    return targetDir

endfunction

function! SyntaxCheckers_java_GetLocList()

    let basepom = findfile('pom.xml', '.;')

    if ! empty( basepom )

        " We'll need to do this for both directories.
        let classdir = (match(expand('%:p'),'.*src.test.*') ? 'classes' : 'test-classes')
        let otherclassdir = (match(expand('%:p'),'.*src.test.*') ? 'test-classes' : 'classes')

        " generate all the relevant maven directories.
        " We're switching to relative paths since it seems that maven doesn't talk to
        " cygwin about where to write a file
        let baseDir = fnamemodify(basepom, ':h') 
        let target = SyntaxCheckers_java_getTargetDir(baseDir, classdir)
        let othertarget = SyntaxCheckers_java_getTargetDir(baseDir, otherclassdir)

        " We cache the classpath in a file in the base directory.
        let classpathFile = '.syntastic_classpath'
        let classpathPathFile = baseDir . '/' . classpathFile

        " Generate classpath if needed
        " NOTE: Maven will take at least 4 seconds to run. TRY TO AVOID THAT
        if (getftime(classpathPathFile) < getftime(basepom))
             echo 'Generating classpath for ' . basepom . '...'

             call system('mvn -o -f ' . shellescape(basepom) . ' '
                \. shellescape('-Dmdep.outputFile=' . classpathFile) . ' '
                \. ' -Dmdep.regenerateFile=true '
                \. ' dependency:build-classpath')

        endif

        " Path separators are different between windows and unix
        if has('win32') || has ('win64') || has('win32unix')
            let pathSeparator = ';'
        else
            let pathSeparator = ':'
        endif

        " Classpath = all the related jars + the different classpath
        let classpath = readfile(classpathPathFile)[0] 
                \. pathSeparator . target
                \. pathSeparator . othertarget

        " Compile.

        let fname = expand('%')

        let makeprg = 'javac -Xlint -d ' . shellescape(target)
                    \. ' -cp ' . shellescape(classpath) . ' '
                    \. shellescape(fname)

        let g:makeprg = makeprg
    else
        " It's not maven. just go back to the old way.
        let makeprg = 'javac -Xlint ' . shellescape(expand('%'))

    endif
    " Column classifier was giving issues on windows. The error message is
    " more useful than the error column IMO.
    let errorformat = '%E%f:%l:\ %m'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

endfunction
