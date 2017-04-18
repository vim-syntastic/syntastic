"============================================================================
"File:        typescript/tslint.vim
"Description: TypeScript linter
"Maintainer:  Seon-Wook Park <seon.wook@swook.net>
"============================================================================

if exists('g:loaded_syntastic_typescript_tslint_checker')
    finish
endif
let g:loaded_syntastic_typescript_tslint_checker = 1

if !exists('g:syntastic_typescript_tslint_sort')
    let g:syntastic_typescript_tslint_sort = 1
endif

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_typescript_tslint_GetHighlightRegex(item)
    let term = matchstr(a:item['text'], "\\m\\s'\\zs.\\{-}\\ze'\\s")
    return term !=# '' ? '\V' . escape(term, '\') : ''
endfunction

function! SyntaxCheckers_typescript_tslint_GetLocList() dict
    if !exists('s:tslint_new')
        let s:tslint_new = syntastic#util#versionIsAtLeast(self.getVersion(), [2, 4])
    endif

    if !exists('s:tslint_major_version')
        let s:tslint_major_version = self.getVersion()[0]
    endif

    if exists(':TsuStartServer')
        " If tsuquyomi is installed, ask for the config file name
        let s:tsconfig = tsuquyomi#tsClient#tsProjectInfo(@%, 0)['configFileName']

        if s:tslint_major_version >= 5
            " tslint v5 requires tsconfig file specified for some rules
            let s:tsargs = '--type-check -p ' . s:tsconfig
        endif
    endif

    let makeprg = self.makeprgBuild({
        \ 'args_after': (exists('s:tsargs') ? s:tsargs : ''),
        \ 'fname_before': (s:tslint_new ? '' : '-f') })

    " Example output:
    " ts/app.ts[12, 36]: comment must start with lowercase letter
    if s:tslint_major_version >= 5
        let errorformat = 'ERROR: %f[%l\, %c]: %m'
    else
        let errorformat = '%f[%l\, %c]: %m'
    endif

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'preprocess': 'tslint',
        \ 'subtype': 'Style',
        \ 'returns': [0, 2] })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'typescript',
    \ 'name': 'tslint'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
