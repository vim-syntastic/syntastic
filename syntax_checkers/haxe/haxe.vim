"============================================================================
"File:        haxe.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  David Bernard <david.bernard.31 at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists("g:loaded_syntastic_haxe_haxe_checker")
    finish
endif
let g:loaded_syntastic_haxe_haxe_checker=1

function! SyntaxCheckers_haxe_haxe_IsAvailable()
    return executable('haxe')
endfunction

" start in directory a:where and walk up the parent folders until it
" finds a file matching a:what; return path to that file
function! s:FindInParent(what, where)
    let here = fnamemodify(a:where, ':p')

    while !empty(here)
        let p = split(globpath(here, a:what), '\n')

        if !empty(p)
            return fnamemodify(p[0], ':p')
        elseif here == '/'
            break
        endif

        " we use ':h:h' rather than ':h' since ':p' adds a trailing '/'
        " if 'here' is a directory
        let here = fnamemodify(here, ':p:h:h')
    endwhile

    return ''
endfunction

function! SyntaxCheckers_haxe_haxe_GetLocList()
    if exists('b:vaxe_hxml')
        let hxml = b:vaxe_hxml
    elseif exists('g:vaxe_hxml')
        let hxml = g:vaxe_hxml
    else
        let hxml = s:FindInParent('*.hxml', expand('%:p:h'))
    endif
    let hxml = fnamemodify(hxml, ':p')

    if !empty(hxml)
        let makeprg = syntastic#makeprg#build({
            \ 'exe': 'haxe',
            \ 'fname': shellescape(fnameescape(fnamemodify(hxml, ':t'))),
            \ 'filetype': 'haxe',
            \ 'subchecker': 'haxe' })

        let errorformat = '%E%f:%l: characters %c-%*[0-9] : %m'

        return SyntasticMake({
            \ 'makeprg': makeprg,
            \ 'errorformat': errorformat,
            \ 'cwd': fnamemodify(hxml, ':h') })
    endif

    return []
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'haxe',
    \ 'name': 'haxe'})
