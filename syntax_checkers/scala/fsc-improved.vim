"============================================================================
"File:        fsc_improved
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Emily St. <hello@emily.st>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists('g:loaded_syntastic_scala_fsc_improved_checker')
    finish
endif
let g:loaded_syntastic_scala_fsc_improved_checker = 1

if !exists('g:syntastic_scala_fsc_improved_classpath_file')
    let g:syntastic_scala_fsc_improved_classpath_file = '.classpath'
endif

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_scala_fsc_improved_GetLocList() dict
    let args = '
        \ -Xfatal-warnings:false
        \ -Xfuture
        \ -Xlint
        \ -Ywarn-adapted-args
        \ -Ywarn-dead-code
        \ -Ywarn-inaccessible
        \ -Ywarn-infer-any
        \ -Ywarn-nullary-override
        \ -Ywarn-nullary-unit
        \ -Ywarn-numeric-widen
        \ -Ywarn-unused-import
        \ -Ywarn-value-discard
        \ -deprecation
        \ -encoding UTF-8
        \ -feature
        \ -language:existentials
        \ -language:higherKinds
        \ -language:implicitConversions
        \ -unchecked
        \ -d ' . syntastic#util#tmpdir() . '
        \ -classpath ' . s:LoadClasspathsFromFile(g:syntastic_scala_fsc_improved_classpath_file)

    let makeprg = self.makeprgBuild({
        \ 'args':  args,
        \ 'fname': syntastic#util#shexpand('%: p') })

    let errorformat =
        \ '%E%f:%l: %trror:%m,' .
        \ '%W%f:%l: %tarning:%m,' .
        \ '%Z%p^,' .
        \ '%-G%.%#,'

    return SyntasticMake({
        \ 'makeprg':     makeprg,
        \ 'errorformat': errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'scala',
    \ 'name':     'fsc_improved',
    \ 'exec':     'fsc' })

function! s:LoadClasspathsFromFile(filename)
    let classpath_file = syntastic#util#shexpand('%:p:h') . syntastic#util#Slash() . a:filename
    if filereadable(classpath_file)
        return join(readfile(classpath_file), s:ClassSep())
    else
        let classpath_file = syntastic#util#findFileInParent(a:filename, syntastic#util#shexpand('%:p:h'))
        if filereadable(classpath_file)
            return join(readfile(classpath_file), s:ClassSep())
        else
            return ''
        endif
    endif
endfunction

function! s:ClassSep()
    return (syntastic#util#isRunningWindows() || has('win32unix')) ? ';' : ':'
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
