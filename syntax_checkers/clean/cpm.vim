"============================================================================
"File:        cpm.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Camil Staps <info at camilstaps dot nl>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists('g:loaded_syntastic_clean_cpm_checker')
    finish
endif
let g:loaded_syntastic_clean_cpm_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_clean_cpm_GetLocList() dict
    let module = expand('%:t:r', 1)
    let prj = module . '.prj'

    if filereadable(prj)
        " Use a .prj (project file) with the same name as the current module.
        let cwd = expand('%:p:h', 1)
        let makeprg = self.makeprgBuild({
                    \ 'exe_after': 'project',
                    \ 'fname': syntastic#util#shescape(prj),
                    \ 'post_args_before': 'build' })
    else
        " If the current module does not have a corresponding project file,
        " simply run cpm make in the first directory we find with a .prj file.
        " This means that if none of the projects in the directory first found
        " use the current module, it won't be checked.
        let prj = syntastic#util#findGlobInParent('*.prj', expand('%:p:h', 1))
        let cwd = fnamemodify(prj, ':h')
        let makeprg = self.makeprgBuild({ 'args': 'make' })
    endif

    " (Mainly) from timjs/clean-vim
    let errorformat  = '%E%trror [%f\,%l]: %m' " General error (without location info)
    let errorformat .= ',%E%trror [%f\,%l\,]: %m' " General error (without location info)
    let errorformat .= ',%E%trror [%f\,%l\,%s]: %m' " General error
    let errorformat .= ',%E%type error [%f\,%l\,%s]:%m' " Type error
    let errorformat .= ',%E%tverloading error [%f\,%l\,%s]:%m' " Overloading error
    let errorformat .= ',%E%tniqueness error [%f\,%l\,%s]:%m' " Uniqueness error
    let errorformat .= ',%E%tarse error [%f\,%l;%c\,%s]: %m' " Parse error
    let errorformat .= ',%+C %m' " Extra info
    let errorformat .= ',%-G%s' " Ignore rest

    return SyntasticMake({
                \ 'cwd': cwd,
                \ 'makeprg': makeprg,
                \ 'errorformat': errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'clean',
    \ 'name': 'cpm' })

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
