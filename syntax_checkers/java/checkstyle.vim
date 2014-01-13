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

if exists("g:loaded_syntastic_java_checkstyle_checker")
    finish
endif
let g:loaded_syntastic_java_checkstyle_checker = 1

if !exists("g:syntastic_java_checkstyle_classpath")
    let g:syntastic_java_checkstyle_classpath = 'checkstyle-5.5-all.jar'
endif

if !exists("g:syntastic_java_checkstyle_conf_file")
    let g:syntastic_java_checkstyle_conf_file = 'sun_checks.xml'
endif

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_java_checkstyle_Preprocess(errors)
    let out = []
    let fname = expand('%')
    for err in a:errors
        if match(err, '\m<error line="') > -1
            let parts = matchlist(err,
                \ '\v\<error line\="(\d+)"( column\="(\d+)")? severity\="(.)[^"]*" message\="([^"]+)"')
            if len(parts) < 6 || str2nr(parts[1]) == 0
                continue
            endif
            call add(out, join([fname,
                \ parts[4], parts[1], str2nr(parts[3]), syntastic#util#decodeXMLEntities(parts[5])], ':'))
        elseif match(err, '\m<file name="') > -1
            let fname = syntastic#util#decodeXMLEntities(matchstr(err, '\v\<file name\="\zs[^"]+\ze"'))
        endif
    endfor
    return out
endfunction

function! SyntaxCheckers_java_checkstyle_GetLocList() dict

    let fname = syntastic#util#shescape( expand('%:p:h') . '/' . expand('%:t') )

    if has('win32unix')
        let fname = substitute(system('cygpath -m ' . fname), '\m\%x00', '', 'g')
    endif

    let makeprg = self.makeprgBuild({
        \ 'args': '-cp ' . g:syntastic_java_checkstyle_classpath .
        \         ' com.puppycrawl.tools.checkstyle.Main -c ' . g:syntastic_java_checkstyle_conf_file .
        \         ' -f xml',
        \ 'fname': fname })

    let errorformat = '%f:%t:%l:%c:%m'

    let loclist = SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'subtype': 'Style',
        \ 'preprocess': 'SyntaxCheckers_java_checkstyle_Preprocess' })

    for e in loclist
        if e['type'] !~? '\m^[EW]'
            let e['type'] = 'E'
        endif
    endfor

    return loclist
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'java',
    \ 'name': 'checkstyle',
    \ 'exec': 'java'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sts=4 sw=4:
