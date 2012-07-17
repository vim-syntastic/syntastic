"============================================================================
"File:        ada.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Alfredo Di Napoli <alfredo.dinapoli@gmail.com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. 
"
"============================================================================

" in order to also check header files add this to your .vimrc:
" (this usually creates a .gch file in your source directory)
"
"   let g:syntastic_ada_check_header = 1
"
" To disable the search of included header files after special
" libraries like gtk and glib add this line to your .vimrc:
"
"   let g:syntastic_ada_no_include_search = 1
"
" In order to add some custom include directories that should be added to the
" gcc command line you can add those to the global variable
" g:syntastic_ada_include_dirs. This list can be used like this:
"
"   let g:syntastic_ada_include_dirs = [ 'includes', 'headers' ]
"
" To enable header files being re-checked on every file write add the
" following line to your .vimrc. Otherwise the header files are checked only
" one time on initially loading the file.
" In order to force syntastic to refresh the header includes simply
" unlet b:syntastic_ada_includes. Then the header files are being re-checked
" on the next file write.
"
"   let g:syntastic_ada_auto_refresh_includes = 1
"
" Alternatively you can set the buffer local variable b:syntastic_ada_cflags.
" If this variable is set for the current buffer no search for additional
" libraries is done. I.e. set the variable like this:
"
"   let b:syntastic_ada_cflags = ' -I/usr/include/libsoup-2.4'
"
" Moreover it is possible to add additional compiler options to the syntax
" checking execution via the variable 'g:syntastic_ada_compiler_options':
"
"   let g:syntastic_ada_compiler_options = ' -std=c++0x'
"
" Additionally the setting 'g:syntastic_ada_config_file' allows you to define
" a file that contains additional compiler arguments like include directories
" or CFLAGS. The file is expected to contain one option per line. If none is
" given the filename defaults to '.syntastic_ada_config':
"
"   let g:syntastic_ada_config_file = '.config'
"
" Using the global variable 'g:syntastic_ada_remove_include_errors' you can
" specify whether errors of files included via the
" g:syntastic_ada_include_dirs' setting are removed from the result set:
"
"   let g:syntastic_ada_remove_include_errors = 1

if exists('loaded_ada_syntax_checker')
    finish
endif
let loaded_ada_syntax_checker = 1

if !executable('gcc')
    finish
endif

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:syntastic_ada_config_file')
    let g:syntastic_ada_config_file = '.syntastic_ada_config'
endif

function! SyntaxCheckers_ada_GetLocList()
    let makeprg = 'gcc -c -fsyntax-only '
    let errorformat =  '%-G%f:%s:,%f:%l:%c: %m,%f:%l: %m'

    if exists('g:syntastic_ada_compiler_options')
        let makeprg .= g:syntastic_ada_compiler_options
    endif

    let makeprg .= ' ' . shellescape(expand('%')) .
                \ ' ' . syntastic#c#GetIncludeDirs('ada')

    if expand('%') =~? '\%(.h\|.hpp\|.hh\)$'
        if exists('g:syntastic_ada_check_header')
            let makeprg = 'g++ -c '.shellescape(expand('%')).
                        \ ' ' . syntastic#c#GetIncludeDirs('ada')
        else
            return []
        endif
    endif

    if !exists('b:syntastic_ada_cflags')
        if !exists('g:syntastic_ada_no_include_search') ||
                    \ g:syntastic_ada_no_include_search != 1
            if exists('g:syntastic_ada_auto_refresh_includes') &&
                        \ g:syntastic_ada_auto_refresh_includes != 0
                let makeprg .= syntastic#c#SearchHeaders()
            else
                if !exists('b:syntastic_ada_includes')
                    let b:syntastic_ada_includes = syntastic#c#SearchHeaders()
                endif
                let makeprg .= b:syntastic_ada_includes
            endif
        endif
    else
        let makeprg .= b:syntastic_ada_cflags
    endif

    " add optional config file parameters
    let makeprg .= ' ' . syntastic#c#ReadConfig(g:syntastic_ada_config_file)

    " process makeprg
    let errors = SyntasticMake({ 'makeprg': makeprg,
                \ 'errorformat': errorformat })

    " filter the processed errors if desired
    if exists('g:syntastic_ada_remove_include_errors') &&
                \ g:syntastic_ada_remove_include_errors != 0
        return filter(errors,
                    \ 'has_key(v:val, "bufnr") && v:val["bufnr"]=='.bufnr(''))
    else
        return errors
    endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sts=4 sw=4:
