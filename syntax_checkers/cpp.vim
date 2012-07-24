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
"
" To disable the search of included header files after special
" libraries like gtk and glib add this line to your .vimrc:
"
"   let g:syntastic_cpp_no_include_search = 1
"
" In order to add some custom include directories that should be added to the
" gcc command line you can add those to the global variable
" g:syntastic_cpp_include_dirs. This list can be used like this:
"
"   let g:syntastic_cpp_include_dirs = [ 'includes', 'headers' ]
"
" To enable header files being re-checked on every file write add the
" following line to your .vimrc. Otherwise the header files are checked only
" one time on initially loading the file.
" In order to force syntastic to refresh the header includes simply
" unlet b:syntastic_cpp_includes. Then the header files are being re-checked
" on the next file write.
"
"   let g:syntastic_cpp_auto_refresh_includes = 1
"
" Alternatively you can set the buffer local variable b:syntastic_cpp_cflags.
" If this variable is set for the current buffer no search for additional
" libraries is done. I.e. set the variable like this:
"
"   let b:syntastic_cpp_cflags = ' -I/usr/include/libsoup-2.4'
"
" Moreover it is possible to add additional compiler options to the syntax
" checking execution via the variable 'g:syntastic_cpp_compiler_options':
"
"   let g:syntastic_cpp_compiler_options = ' -std=c++0x'
"
" Additionally the setting 'g:syntastic_cpp_config_file' allows you to define
" a file that contains additional compiler arguments like include directories
" or CFLAGS. The file is expected to contain one option per line. If none is
" given the filename defaults to '.syntastic_cpp_config':
"
"   let g:syntastic_cpp_config_file = '.config'
"
" Using the global variable 'g:syntastic_cpp_remove_include_errors' you can
" specify whether errors of files included via the
" g:syntastic_cpp_include_dirs' setting are removed from the result set:
"
"   let g:syntastic_cpp_remove_include_errors = 1
"
" Use the variable 'g:syntastic_cpp_errorformat' to override the default error
" format:
"
"   let g:syntastic_cpp_errorformat = '%f:%l:%c: %trror: %m'
"
" Set your compiler executable with e.g. (defaults to g++)
"
"   let g:syntastic_cpp_compiler = 'clang++' 

if exists('loaded_cpp_syntax_checker')
    finish
endif
let loaded_cpp_syntax_checker = 1

if !exists('g:syntastic_cpp_compiler')
    let g:syntastic_cpp_compiler = 'g++'
endif

if !executable(g:syntastic_cpp_compiler)
    finish
endif

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:syntastic_cpp_config_file')
    let g:syntastic_cpp_config_file = '.syntastic_cpp_config'
endif

function! SyntaxCheckers_cpp_GetLocList()
    let makeprg = g:syntastic_cpp_compiler . ' -fsyntax-only '
    let errorformat =  '%-G%f:%s:,%f:%l:%c: %trror: %m,%f:%l:%c: %tarning: '.
                \ '%m,%f:%l:%c: %m,%f:%l: %trror: %m,%f:%l: %tarning: %m,'.
                \ '%f:%l: %m'

    if exists('g:syntastic_cpp_errorformat')
        let errorformat = g:syntastic_cpp_errorformat
    endif

    if exists('g:syntastic_cpp_compiler_options')
        let makeprg .= g:syntastic_cpp_compiler_options
    endif

    let makeprg .= ' ' . shellescape(expand('%')) .
                \ ' ' . syntastic#c#GetIncludeDirs('cpp')

    if expand('%') =~? '\%(.h\|.hpp\|.hh\)$'
        if exists('g:syntastic_cpp_check_header')
            let makeprg = g:syntastic_cpp_compiler.' -c '.shellescape(expand('%')).
                        \ ' ' . syntastic#c#GetIncludeDirs('cpp')
        else
            return []
        endif
    endif

    if !exists('b:syntastic_cpp_cflags')
        if !exists('g:syntastic_cpp_no_include_search') ||
                    \ g:syntastic_cpp_no_include_search != 1
            if exists('g:syntastic_cpp_auto_refresh_includes') &&
                        \ g:syntastic_cpp_auto_refresh_includes != 0
                let makeprg .= syntastic#c#SearchHeaders()
            else
                if !exists('b:syntastic_cpp_includes')
                    let b:syntastic_cpp_includes = syntastic#c#SearchHeaders()
                endif
                let makeprg .= b:syntastic_cpp_includes
            endif
        endif
    else
        let makeprg .= b:syntastic_cpp_cflags
    endif

    " add optional config file parameters
    let makeprg .= ' ' . syntastic#c#ReadConfig(g:syntastic_cpp_config_file)

    " process makeprg
    let errors = SyntasticMake({ 'makeprg': makeprg,
                \ 'errorformat': errorformat })

    " filter the processed errors if desired
    if exists('g:syntastic_cpp_remove_include_errors') &&
                \ g:syntastic_cpp_remove_include_errors != 0
        return filter(errors,
                    \ 'has_key(v:val, "bufnr") && v:val["bufnr"]=='.bufnr(''))
    else
        return errors
    endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sts=4 sw=4:
