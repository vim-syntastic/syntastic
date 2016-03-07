"============================================================================
"File:        smlnj.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  LCD 47 <lcd047 at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists('g:loaded_syntastic_sml_smlnj_checker')
    finish
endif
let g:loaded_syntastic_sml_smlnj_checker = 1

let s:save_cpo = &cpo
set cpo&vim

" If the user is using a CM file to manage their program, we'd like to detect
" this and set the flags for makeprgBuild appropriately.
"
" This function basically automates this process which formerly required user
" intervention:
"
"   - Figure out whether the project is using a CM file
"   - Figure out the name of the CM file for this project
"   - Edit the vimrc, using the appropriate name:
"         let g:syntastic_sml_smlnj_args = "-m sources.cm"
"         let g:syntastic_sml_smlnj_fname = ""
"   - Re-launch Vim
"
" Of course none of these are that hard, but it's tedious to have to edit the
" vimrc every time you start working in a different folder on a new project.

function! s:DetectCMFile()
    " Start searching at the current folder
    let curdir = fnamemodify("%", ":p:h")

    while 1
        " Check if there are any cm files in the current folder
        let cmfiles = split(globpath(curdir, "*.cm"))
        if len(cmfiles) > 0
            " Return the first CM file. The user can always override which
            " CM file is used according to the procedure discussed above.
            "
            " TODO(jez): This is a bad heuristic if there are many CM files.
            return cmfiles[0]
        endif

        let nextdir = fnamemodify(curdir, ":h")
        if nextdir ==# curdir
            break
        else
            let curdir = nextdir
        endif
    endwhile

endfunction

function! SyntaxCheckers_sml_smlnj_GetLocList() dict
    let cmfile = s:DetectCMFile()
    if !empty(cmfile)
        " Use the CM file we found
        let makeprg = self.makeprgBuild({"args": "-m " . cmfile, "fname": ""})
    else
        " Default to running smlnj on the current file
        let makeprg = self.makeprgBuild({})
    endif

    let errorformat =
        \ '%E%f:%l%\%.%c %trror: %m,' .
        \ '%E%f:%l%\%.%c-%\d%\+%\%.%\d%\+ %trror: %m,' .
        \ '%W%f:%l%\%.%c %tarning: %m,' .
        \ '%W%f:%l%\%.%c-%\d%\+%\%.%\d%\+ %tarning: %m,' .
        \ '%C%\s%\+%m,' .
        \ '%-G%.%#'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'postprocess': ['compressWhitespace'],
        \ 'returns': [0, 1] })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'sml',
    \ 'name': 'smlnj',
    \ 'exec': 'sml'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
