"============================================================================
"File:        checkstyle.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Dmitry Geurkov <d.geurkov at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
" Tested with checkstyle 5.5
"============================================================================
if !exists("g:syntastic_java_checkstyle_classpath")
    let g:syntastic_java_checkstyle_classpath = 'checkstyle-5.5-all.jar'
endif

if !exists("g:syntastic_java_checkstyle_conf_file")
    let g:syntastic_java_checkstyle_conf_file = 'sun_checks.xml'
endif

function! SyntaxCheckers_java_GetLocList()

    let makeprg = 'java -cp ' . g:syntastic_java_checkstyle_classpath . ' com.puppycrawl.tools.checkstyle.Main -c '
               \. g:syntastic_java_checkstyle_conf_file . ' '
               \. expand ( '%:p:h' ) . '/' . expand ( '%:t' )
               \. ' 2>&1 '

    " check style format
    let errorformat = '%f:%l:%c:\ %m,%f:%l:\ %m'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

endfunction
