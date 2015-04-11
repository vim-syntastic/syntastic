"============================================================================
"File:        tsc.vim
"Description: TypeScript syntax checker
"Maintainer:  Bill Casarin <bill@casarin.ca>
"============================================================================

if exists('g:loaded_syntastic_typescript_tsc_checker')
    finish
endif
let g:loaded_syntastic_typescript_tsc_checker = 1

if !exists('g:syntastic_typescript_tsc_sort')
    let g:syntastic_typescript_tsc_sort = 1
endif

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_typescript_tsc_GetLocList() dict
    if !exists('s:tsc_new')
        let s:tsc_new = -1
        try
            let tsc_version = filter(split(syntastic#util#system(self.getExecEscaped() . ' --version'), '\n'), 'v:val =~# ''\m\<Version ''')[0]
            let ver = syntastic#util#parseVersion(tsc_version, '\v<Version \zs\d+(\.\d+)\ze')
            call self.setVersion(ver)

            let s:tsc_new = syntastic#util#versionIsAtLeast(ver, [1, 5])
        catch /\m^Vim\%((\a\+)\)\=:E684/
            call syntastic#log#error("checker typescript/tsc: can't parse version string (abnormal termination?)")
        endtry
    endif

    if s:tsc_new < 0
        return []
    endif

    let makeprg = self.makeprgBuild({
        \ 'args': '--module commonjs',
        \ 'args_after': (s:tsc_new ? '--noEmit' : '--out ' . syntastic#util#DevNull()) })

    let errorformat =
        \ '%E%f %#(%l\,%c): error %m,' .
        \ '%E%f %#(%l\,%c): %m,' .
        \ '%Eerror %m,' .
        \ '%C%\s%\+%m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'defaults': {'bufnr': bufnr('')} })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'typescript',
    \ 'name': 'tsc'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
