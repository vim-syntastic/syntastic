if exists("g:loaded_syntastic_c_autoload")
    finish
endif
let g:loaded_syntastic_c_autoload = 1

let s:save_cpo = &cpo
set cpo&vim

" initialize c/cpp syntax checker handlers
function! s:Init()
    let s:handlers = []
    let s:cflags = {}

    call s:RegHandler('gtk', 'syntastic#c#CheckPKG',
                \ ['gtk', 'gtk+-2.0', 'gtk+', 'glib-2.0', 'glib'])
    call s:RegHandler('glib', 'syntastic#c#CheckPKG',
                \ ['glib', 'glib-2.0', 'glib'])
    call s:RegHandler('glade', 'syntastic#c#CheckPKG',
                \ ['glade', 'libglade-2.0', 'libglade'])
    call s:RegHandler('libsoup', 'syntastic#c#CheckPKG',
                \ ['libsoup', 'libsoup-2.4', 'libsoup-2.2'])
    call s:RegHandler('webkit', 'syntastic#c#CheckPKG',
                \ ['webkit', 'webkit-1.0'])
    call s:RegHandler('cairo', 'syntastic#c#CheckPKG',
                \ ['cairo', 'cairo'])
    call s:RegHandler('pango', 'syntastic#c#CheckPKG',
                \ ['pango', 'pango'])
    call s:RegHandler('libxml', 'syntastic#c#CheckPKG',
                \ ['libxml', 'libxml-2.0', 'libxml'])
    call s:RegHandler('freetype', 'syntastic#c#CheckPKG',
                \ ['freetype', 'freetype2', 'freetype'])
    call s:RegHandler('SDL', 'syntastic#c#CheckPKG',
                \ ['sdl', 'sdl'])
    call s:RegHandler('opengl', 'syntastic#c#CheckPKG',
                \ ['opengl', 'gl'])
    call s:RegHandler('ruby', 'syntastic#c#CheckRuby', [])
    call s:RegHandler('Python\.h', 'syntastic#c#CheckPython', [])
    call s:RegHandler('php\.h', 'syntastic#c#CheckPhp', [])
endfunction

" search the first 100 lines for include statements that are
" given in the handlers dictionary
function! syntastic#c#SearchHeaders()
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
function! syntastic#c#CheckPKG(name, ...)
    if executable('pkg-config')
        if !has_key(s:cflags, a:name)
            for i in range(a:0)
                let l:cflags = system('pkg-config --cflags '.a:000[i])
                " since we cannot necessarily trust the pkg-config exit code
                " we have to check for an error output as well
                if v:shell_error == 0 && l:cflags !~? 'not found'
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
function! syntastic#c#CheckPhp()
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
function! syntastic#c#CheckRuby()
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
function! syntastic#c#CheckPython()
    if executable('python')
        if !exists('s:python_flags')
            let s:python_flags = system('python -c ''from distutils import '
                        \ . 'sysconfig; import sys; sys.stdout.write(sysconfig.get_python_inc())''')
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

" vim: set et sts=4 sw=4:
