"============================================================================
"File:        flake8.vim
"Description: Syntax checking plugin for syntastic
"Authors:     Sylvain Soliman <Sylvain dot Soliman+git at gmail dot com>
"             kstep <me@kstep.me>
"
"============================================================================

if exists('g:loaded_syntastic_python_flake8_checker')
    finish
endif
let g:loaded_syntastic_python_flake8_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_python_flake8_GetHighlightRegex(item)
    return SyntaxCheckers_python_pyflakes_GetHighlightRegex(a:item)
endfunction

function! SyntaxCheckers_python_flake8_GetLocList() dict
    let makeprg = self.makeprgBuild({})

    let errorformat =
        \ '%E%f:%l: could not compile,%-Z%p^,' .
        \ '%A%f:%l:%c: %m,' .
        \ '%A%f:%l: %m,' .
        \ '%-G%.%#'

    let env = syntastic#util#isRunningWindows() ? {} : { 'TERM': 'dumb' }

    let loclist = SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'env': env })

    for e in loclist
        " flake8 codes: https://gitlab.com/pycqa/flake8/issues/339

        let parts = matchlist(e['text'], '\v\C^([A-Z]+)(\d+):?\s+(.*)')
        if len(parts) >= 4
            let e['type'] = parts[1][0]
            let e['text'] = printf('%s [%s%s]', parts[3], parts[1], parts[2])

            if e['type'] ==? 'E' && parts[2] !~# '\m^9'
                let e['subtype'] = 'Style'
            endif
        else
            let e['type'] = 'E'
        endif

        if e['type'] =~? '\m^[CHIMNRTW]'
            let e['subtype'] = 'Style'
        endif

        let e['type'] = e['type'] =~? '\m^[EFHC]' ? 'E' : 'W'
    endfor

    return loclist
endfunction

runtime! syntax_checkers/python/pyflakes.vim

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'python',
    \ 'name': 'flake8'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
