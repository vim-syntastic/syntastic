"============================================================================
"File:        pylint.vim
"Description: Syntax checking plugin for syntastic.vim
"Author:      Parantapa Bhattacharya <parantapa at gmail dot com>
"
"============================================================================
if exists("g:loaded_syntastic_python_pylint_checker")
    finish
endif
let g:loaded_syntastic_python_pylint_checker = 1

let s:pylint_new = -1

function! SyntaxCheckers_python_pylint_IsAvailable() dict
    let exe = self.getExec()
    let s:pylint_new = executable(exe) ? s:PylintNew(exe) : -1
    return s:pylint_new >= 0
endfunction

function! SyntaxCheckers_python_pylint_GetLocList() dict
    let makeprg = self.makeprgBuild({
        \ 'args': (s:pylint_new ? '--msg-template="{path}:{line}: [{msg_id}] {msg}" -r n' : '-f parseable -r n -i y') })

    let errorformat =
        \ '%A%f:%l: %m,' .
        \ '%A%f:(%l): %m,' .
        \ '%-Z%p^%.%#,' .
        \ '%-G%.%#'

    let loclist=SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'postprocess': ['sort'] })

    for e in loclist
        let type = e['text'][1]
        if type =~# '\m^[EF]'
            let e['type'] = 'E'
        elseif type =~# '\m^[CRW]'
            let e['type'] = 'W'
        else
            let e['valid'] = 0
        endif
        let e['vcol'] = 0
    endfor

    return loclist
endfunction

function! s:PylintNew(exe)
    try
        " On Windows the version is shown as "pylint-script.py 1.0.0".
        " On Gentoo Linux it's "pylint-python2.7 0.28.0".  Oh, joy. :)
        let pylint_version = filter(split(system(a:exe . ' --version'), '\m, \=\|\n'), 'v:val =~# ''\m^pylint\>''')[0]
        let pylint_version = substitute(pylint_version, '\v^\S+\s+', '', '')
        let ret = syntastic#util#versionIsAtLeast(syntastic#util#parseVersion(pylint_version), [1])
    catch /^Vim\%((\a\+)\)\=:E684/
        call syntastic#log#error("checker python/pylint: can't parse version string (abnormal termination?)")
        let ret = -1
    endtry
    return ret
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'python',
    \ 'name': 'pylint' })
