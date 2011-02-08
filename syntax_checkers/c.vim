"============================================================================
"File:        c.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Gregor Uhlenheuer <kongo2002 at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

" In order to also check header files add this to your .vimrc:
" (this usually creates a .gch file in your source directory)
"
"   let g:syntastic_c_check_header = 1
"
" To disable the search of included header files after special
" libraries like gtk and glib add this line to your .vimrc:
"
"   let g:syntastic_c_no_include_search = 1
"
" To enable header files being re-checked on every file write add the
" following line to your .vimrc. Otherwise the header files are checked only
" one time on initially loading the file.
" In order to force syntastic to refresh the header includes simply
" unlet b:syntastic_c_includes. Then the header files are being re-checked on
" the next file write.
"
"   let g:syntastic_c_auto_refresh_includes = 1
"
" Alternatively you can set the buffer local variable b:syntastic_c_cflags.
" If this variable is set for the current buffer no search for additional
" libraries is done. I.e. set the variable like this:
"
"   let b:syntastic_c_cflags = ' -I/usr/include/libsoup-2.4'

if exists('loaded_c_syntax_checker')
    finish
endif
let loaded_c_syntax_checker = 1

if !executable('gcc')
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

function! SyntaxCheckers_c_GetLocList()
    let makeprg = 'gcc -fsyntax-only '.shellescape(expand('%')).' -I. -I..'
    let errorformat = '%-G%f:%s:,%-G%f:%l: %#error: %#(Each undeclared '.
                \ 'identifier is reported only%.%#,%-G%f:%l: %#error: %#for '.
                \ 'each function it appears%.%#,%-GIn file included%.%#,'.
                \ '%-G %#from %f:%l\,,%f:%l: %trror: %m,%f:%l: %m'

    if expand('%') =~? '.h$'
        if exists('g:syntastic_c_check_header')
            let makeprg = 'gcc -c '.shellescape(expand('%')).' -I. -I..'
        else
            return []
        endif
    endif

    if !exists('b:syntastic_c_cflags')
        if !exists('g:syntastic_c_no_include_search') ||
                    \ g:syntastic_c_no_include_search != 1
            if exists('g:syntastic_c_auto_refresh_includes') &&
                        \ g:syntastic_c_auto_refresh_includes != 0
                let makeprg .= s:SearchHeaders()
            else
                if !exists('b:syntastic_c_includes')
                    let b:syntastic_c_includes = s:SearchHeaders()
                endif
                let makeprg .= b:syntastic_c_includes
            endif
        endif
    else
        let makeprg .= b:syntastic_c_cflags
    endif

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
