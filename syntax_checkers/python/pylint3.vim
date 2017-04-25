"============================================================================
"File:        pylint3.vim
"Description: Syntax checking plugin for syntastic.vim
"Author:      Parantapa Bhattacharya <parantapa at gmail dot com>
"
"============================================================================

if exists("g:loaded_syntastic_python_pylint3_checker")
    finish
endif
let g:loaded_syntastic_python_pylint3_checker = 1

let s:pylint3_new = -1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_python_pylint3_IsAvailable() dict
    if !executable(self.getExec())
        return 0
    endif

    try
        " On Windows the version is shown as "pylint3-script.py 1.0.0".
        " On Gentoo Linux it's "pylint3-python2.7 0.28.0".
        " On NixOS, that would be ".pylint3-wrapped 0.26.0".
        " On Arch Linux it's "pylint32 1.1.0".
        " On new-ish Fedora it's "python3-pylint3 1.2.0".
        " Have you guys considered switching to creative writing yet? ;)

        let pylint3_version = filter( split(system(self.getExecEscaped() . ' --version'), '\m, \=\|\n'),
            \ 'v:val =~# ''\m^\(python[-0-9]*-\|\.\)\=pylint3[-0-9]*\>''' )[0]
        let ver = syntastic#util#parseVersion(substitute(pylint3_version, '\v^\S+\s+', '', ''))

        call self.log(self.getExec() . ' version =', ver)

        let s:pylint3_new = syntastic#util#versionIsAtLeast(ver, [1])
    catch /\m^Vim\%((\a\+)\)\=:E684/
        call syntastic#log#error("checker python/pylint3: can't parse version string (abnormal termination?)")
        let s:pylint3_new = -1
    endtry

    return s:pylint3_new >= 0
endfunction

function! SyntaxCheckers_python_pylint3_GetLocList() dict
    let makeprg = self.makeprgBuild({
        \ 'args_after': (s:pylint3_new ?
        \       '-f text --msg-template="{path}:{line}:{column}:{C}: [{symbol}] {msg}" -r n' :
        \       '-f parseable -r n -i y') })

    let errorformat =
        \ '%A%f:%l:%c:%t: %m,' .
        \ '%A%f:%l: %m,' .
        \ '%A%f:(%l): %m,' .
        \ '%-Z%p^%.%#,' .
        \ '%-G%.%#'

    let env = syntastic#util#isRunningWindows() ? {} : { 'TERM': 'dumb' }

    let loclist = SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'env': env,
        \ 'returns': range(32) })

    for e in loclist
        if !s:pylint3_new
            let e['type'] = e['text'][1]
        endif

        if e['type'] =~? '\m^[EF]'
            let e['type'] = 'E'
        elseif e['type'] =~? '\m^[CRW]'
            let e['type'] = 'W'
        else
            let e['valid'] = 0
        endif

        let e['col'] += 1
        let e['vcol'] = 0
    endfor

    call self.setWantSort(1)

    return loclist
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'python',
    \ 'name': 'pylint3' })

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sts=4 sw=4:
