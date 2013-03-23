"============================================================================
"File: checkbashisms.vim
"Description: Syntax/style checking plugin for syntastic.vim
"Maintainer:  András Szilárd <andras dot szilard at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists("g:loaded_syntastic_sh_checkbashisms_checker")
    finish
endif
let g:loaded_syntastic_sh_checkbashisms_checker=1


function! s:IsShShell()
    let shebang = getbufline(bufnr('%'), 1)[0]
    if len(shebang) > 0
        if match(shebang, '\<sh\>') > 0
            return 1
        endif
    endif
    return 0
endfunction


function! SyntaxCheckers_sh_checkbashisms_IsAvailable()
    return executable('checkbashisms')
endfunction


function! SyntaxCheckers_sh_checkbashisms_GetLocList()
    if !s:IsShShell()
        return []
    endif

    let makeprg = syntastic#makeprg#build({'exe': 'checkbashisms'})

    let errorformat =               '%Eerror: %f: %m,'
    let errorformat = errorformat . '%Ecannot open script %f for reading: %m,'
    let errorformat = errorformat . '%Wscript %f %m,%C%.# lines,'
    let errorformat = errorformat . '%Wpossible bashism in %f line %l (%m):,%C%.%#,%Z.%#'

    return SyntasticMake({'makeprg': makeprg, 'errorformat': errorformat})
endfunction


call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'sh',
    \ 'name': 'checkbashisms'})
