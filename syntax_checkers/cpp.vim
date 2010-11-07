"============================================================================
"File:        cpp.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Gregor Uhlenheuer <kongo2002 at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

" in order to also check header files add this to your .vimrc:
" (this usually creates a .gch file in your source directory)
"
"   let g:syntastic_cpp_check_header = 1

if exists('loaded_cpp_syntax_checker')
    finish
endif
let loaded_cpp_syntax_checker = 1

if !executable('g++')
    finish
endif

let s:save_cpo = &cpo
set cpo&vim

" initialize handlers
function! s:Init()
    let s:handlers = []
    let s:cflags = {}

    call s:RegHandler('\%(gtk\|glib\)', 's:CheckPKG',
                \ ['gtk', 'gtk+-2.0', 'gtk+', 'glib-2.0', 'glib'])
    call s:RegHandler('glade', 's:CheckPKG',
                \ ['glade', 'libglade-2.0', 'libglade'])
    call s:RegHandler('libsoup', 's:CheckPKG',
                \ ['libsoup', 'libsoup-2.4', 'libsoup-2.2'])
    call s:RegHandler('webkit', 's:CheckPKG',
                \ ['webkit', 'webkit-1.0'])
    call s:RegHandler('cairo', 's:CheckPKG',
                \ ['cairo', 'cairo'])
    call s:RegHandler('pango', 's:CheckPKG',
                \ ['pango', 'pango'])
    call s:RegHandler('libxml', 's:CheckPKG',
                \ ['libxml', 'libxml-2.0', 'libxml'])
    call s:RegHandler('freetype', 's:CheckPKG',
                \ ['freetype', 'freetype2', 'freetype'])
    call s:RegHandler('SDL', 's:CheckPKG',
                \ ['sdl', 'sdl'])
    call s:RegHandler('opengl', 's:CheckPKG',
                \ ['opengl', 'gl'])
    call s:RegHandler('ruby', 's:CheckRuby', [])
    call s:RegHandler('Python\.h', 's:CheckPython', [])
    call s:RegHandler('php\.h', 's:CheckPhp', [])

    unlet! s:RegHandler
endfunction

function! SyntaxCheckers_cpp_GetLocList()
    let makeprg = 'g++ -std=c++0x -fsyntax-only '.shellescape(expand('%'))
    let errorformat =  '%-G%f:%s:,%f:%l:%c: %m,%f:%l: %m'

    if expand('%') =~? '\%(.h\|.hpp\|.hh\)$'
        if exists('g:syntastic_cpp_check_header')
            let makeprg = 'g++ -std=c++0x -c '.shellescape(expand('%'))
        else
            return []
        endif
    endif

    let makeprg .= s:SearchHeaders()

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction

" search the first 100 lines for include statements that are
" given in the s:handlers dictionary
function! s:SearchHeaders()
    let includes = ''
    let files = []
    let found = []
    let lines = filter(getline(1, 100), 'v:val =~# "#\s*include"')

    " search current buffer
    for line in lines
        let file = matchstr(line, '"\zs\S\+\ze"')
        if file != ''
            call add(files, file)
            continue
        endif
        for handler in s:handlers
            if line =~# handler["regex"]
                let includes .= call(handler["func"], handler["args"])
                call add(found, handler["regex"])
                break
            endif
        endfor
    endfor

    " search included headers
    for hfile in files
        if hfile != ''
            let filename = expand('%:p:h') . ((has('win32') || has('win64')) ?
                        \ '\' : '/') . hfile
            try
                let lines = readfile(filename, '', 100)
            catch /E484/
                continue
            endtry
            let lines = filter(lines, 'v:val =~# "#\s*include"')
            for handler in s:handlers
                if index(found, handler["regex"]) != -1
                    continue
                endif
                for line in lines
                    if line =~# handler["regex"]
                        let includes .= call(handler["func"], handler["args"])
                        call add(found, handler["regex"])
                        break
                    endif
                endfor
            endfor
        endif
    endfor

    return includes
endfunction

" try to find library with 'pkg-config'
" search possible libraries from first to last given
" argument until one is found
function! s:CheckPKG(name, ...)
    if executable('pkg-config')
        if !has_key(s:cflags, a:name)
            for i in range(a:0)
                let l:cflags = system('pkg-config --cflags '.a:000[i])
                if v:shell_error == 0
                    let l:cflags = ' '.substitute(l:cflags, "\n", '', '')
                    let s:cflags[a:name] = l:cflags
                    return l:cflags
                endif
            endfor
        else
            return s:cflags[a:name]
        endif
    endif
    return ''
endfunction

" try to find PHP includes with 'php-config'
function! s:CheckPhp()
    if executable('php-config')
        if !exists('s:php_flags')
            let s:php_flags = system('php-config --includes')
            let s:php_flags = ' ' . substitute(s:php_flags, "\n", '', '')
        endif
        return s:php_flags
    endif
    return ''
endfunction

" try to find the ruby headers with 'rbconfig'
function! s:CheckRuby()
    if executable('ruby')
        if !exists('s:ruby_flags')
            let s:ruby_flags = system('ruby -r rbconfig -e '
                        \ . '''puts Config::CONFIG["archdir"]''')
            let s:ruby_flags = substitute(s:ruby_flags, "\n", '', '')
            let s:ruby_flags = ' -I' . s:ruby_flags
        endif
        return s:ruby_flags
    endif
    return ''
endfunction

" try to find the python headers with distutils
function! s:CheckPython()
    if executable('python')
        if !exists('s:python_flags')
            let s:python_flags = system('python -c ''from distutils import '
                        \ . 'sysconfig; print sysconfig.get_python_inc()''')
            let s:python_flags = substitute(s:python_flags, "\n", '', '')
            let s:python_flags = ' -I' . s:python_flags
        endif
        return s:python_flags
    endif
    return ''
endfunction

" return a handler dictionary object
function! s:RegHandler(regex, function, args)
    let handler = {}
    let handler["regex"] = a:regex
    let handler["func"] = function(a:function)
    let handler["args"] = a:args
    call add(s:handlers, handler)
endfunction

call s:Init()

let &cpo = s:save_cpo
unlet s:save_cpo
