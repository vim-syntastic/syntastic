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

function! SyntaxCheckers_python_pylint_IsAvailable()
    let s:pylint_new = executable('pylint') ? s:PylintNew() : -1
    return s:pylint_new >= 0
endfunction

function! SyntaxCheckers_python_pylint_GetLocList()
    let makeprg = syntastic#makeprg#build({
        \ 'exe': 'pylint',
        \ 'args': (s:pylint_new ? '--msg-template="{path}:{line}: [{msg_id}] {msg}" -r n' : '-f parseable -r n -i y'),
        \ 'filetype': 'python',
        \ 'subchecker': 'pylint' })

    let errorformat =
        \ '%A%f:%l: %m,' .
        \ '%A%f:(%l): %m,' .
        \ '%-Z%p^%.%#,' .
        \ '%-G%.%#'

    let loclist=SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'postprocess': ['sort'] })

    for n in range(len(loclist))
        let type = loclist[n]['text'][1]
        if type =~# '\m^[EF]'
            let loclist[n]['type'] = 'E'
        elseif type =~# '\m^[CRW]'
            let loclist[n]['type'] = 'W'
        else
            let loclist[n]['valid'] = 0
        endif
        let loclist[n]['vcol'] = 0
    endfor

    return loclist
endfunction

function s:PylintNew()
    try
        " On Windows the version is shown as "pylint-script.py 1.0.0"
        let pylint_version = filter(split(system('pylint --version'), '\m, \=\|\n'), 'v:val =~# ''\m^pylint\(-script\.py\)\= ''')[0]
        let ret = syntastic#util#versionIsAtLeast(syntastic#util#parseVersion(pylint_version), [1])
    catch /^Vim\%((\a\+)\)\=:E684/
        call syntastic#util#error("checker python/pylint: can't parse version string (abnormal termination?)")
        let ret = -1
    endtry
    return ret
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'python',
    \ 'name': 'pylint' })
