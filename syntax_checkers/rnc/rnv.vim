"============================================================================
"File:        rnv.vim
"Description: RelaxNG RNV syntax checking plugin for syntastic.vim
"Maintainer:  Remko Tronçon <remko at el-tramo dot be>
"License:     BSD
"============================================================================

if exists("g:loaded_syntastic_rnc_rnv_checker")
        finish
endif
let g:loaded_syntastic_rnc_rnv_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_rnc_rnv_GetLocList() dict
    let makeprg = self.makeprgBuild({ 'args': '-c' })

    let errorformat=
        \ '%f:%l:%c: error: %m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
        \ 'filetype': 'rnc',
        \ 'name': 'rnv'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sts=4 sw=4:
