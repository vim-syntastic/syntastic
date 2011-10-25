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
"
" In order to add some custom include directories that should be added to the
" gcc command line you can add those to the global variable
" g:syntastic_c_include_dirs. This list can be used like this:
"
"   let g:syntastic_c_include_dirs = [ 'includes', 'headers' ]

" Moreover it is possible to add additional compiler options to the syntax
" checking execution via the variable 'g:syntastic_c_compiler_options':
"
"   let g:syntastic_c_compiler_options = ' -ansi'

if exists('loaded_c_syntax_checker')
    finish
endif
let loaded_c_syntax_checker = 1

if !executable('gcc')
    finish
endif

let s:save_cpo = &cpo
set cpo&vim

let s:default_includes = [ '.', '..', 'include', 'includes',
            \ '../include', '../includes' ]

function! s:GetIncludeDirs()
    let include_dirs = s:default_includes

    if exists('g:syntastic_c_include_dirs')
        " TODO: check for duplicates
        call extend(include_dirs, g:syntastic_c_include_dirs)
    endif

    return join(map(copy(include_dirs), '"-I" . v:val'), ' ')
endfunction

function! SyntaxCheckers_c_GetLocList()
    let makeprg = 'gcc -fsyntax-only '.shellescape(expand('%')).
               \ ' '.s:GetIncludeDirs()
    let errorformat = '%-G%f:%s:,%-G%f:%l: %#error: %#(Each undeclared '.
               \ 'identifier is reported only%.%#,%-G%f:%l: %#error: %#for '.
               \ 'each function it appears%.%#,%-GIn file included%.%#,'.
               \ '%-G %#from %f:%l\,,%f:%l:%c: %m,%f:%l: %trror: %m,%f:%l: %m'

    if expand('%') =~? '.h$'
        if exists('g:syntastic_c_check_header')
            let makeprg = 'gcc -c '.shellescape(expand('%')).
                        \ ' '.s:GetIncludeDirs()
        else
            return []
        endif
    endif

    if exists('g:syntastic_c_compiler_options')
        let makeprg .= g:syntastic_c_compiler_options
    endif

    if !exists('b:syntastic_c_cflags')
        if !exists('g:syntastic_c_no_include_search') ||
                    \ g:syntastic_c_no_include_search != 1
            if exists('g:syntastic_c_auto_refresh_includes') &&
                        \ g:syntastic_c_auto_refresh_includes != 0
                let makeprg .= syntastic#SearchHeaders()
            else
                if !exists('b:syntastic_c_includes')
                    let b:syntastic_c_includes = syntastic#SearchHeaders()
                endif
                let makeprg .= b:syntastic_c_includes
            endif
        endif
    else
        let makeprg .= b:syntastic_c_cflags
    endif

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sts=4 sw=4:
