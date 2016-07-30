"============================================================================
"File:        iasl.vim
"Description: Syntax checking plugin for syntastic.vim using iasl
"Maintainer:  Peter Wu <peter@lekensteyn.nl>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"============================================================================

if exists('g:loaded_syntastic_asl_iasl_checker')
    finish
endif
let g:loaded_syntastic_asl_iasl_checker = 1

let s:save_cpo = &cpo
set cpo&vim

" Checker options {{{1

if !exists('g:syntastic_asl_iasl_options')
    let g:syntastic_asl_iasl_options = ''
endif

if !exists('g:syntastic_asl_iasl_delete_output')
    let g:syntastic_asl_iasl_delete_output = 1
endif

" }}}1

function! SyntaxCheckers_asl_iasl_GetLocList() dict " {{{1
    " Enable less verbose messages for use with IDES (MSVC style).
    let iasl_opts = '-vi'

    let output_dir = ''
    if g:syntastic_asl_iasl_delete_output
        let output_dir = syntastic#util#tmpdir()
        let iasl_opts .= ' -p' . syntastic#util#shescape(output_dir)
    endif

    let makeprg = self.makeprgBuild({
        \ 'args': g:syntastic_asl_iasl_options,
        \ 'args_after': iasl_opts })

    " See source/compiler/aslmessages.c for functions that produce output:
    " AePrintException, called via AslCommonError, via AslError.
    " "%s(%u) : %s"             filename, line no, message without ID
    " "%s(%u) : %s %4.4d - %s"  filename, line no, level, exception code, msg
    let errorformat =
        \ '%f(%l) : %trror    %n - %m,' .
        \ '%f(%l) : %tarning  %n - %m,' .
        \ '%f(%l) : %temark   %n - %m,' .
        \ '%f(%l) : %tptimize %n - %m,' .
        \ '%f(%l) : %m'

    if output_dir !=# ''
        silent! call mkdir(output_dir, 'p')
    endif

    let loclist = SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'returns': [0, 255] })

    " Change Remark comments to Warnings. Optimization comments are normally not
    " reported unless '-vo' is added to the iasl options (not a Warning!).
    for e in loclist
        if e['type'] =~? 'r'
            let e['type'] = 'W'
        endif
    endfor

    if output_dir !=# ''
        call syntastic#util#rmrf(output_dir)
    endif

    return loclist
endfunction "}}}1

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'asl',
    \ 'name': 'iasl'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
