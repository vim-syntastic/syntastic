"============================================================================
"File:        frosted.vim
"Description: Syntax checking plugin for syntastic.vim
"Authors:     Martin Grenfell <martin.grenfell@gmail.com>
"             kstep <me@kstep.me>
"             Parantapa Bhattacharya <parantapa@gmail.com>
"
"============================================================================
if exists("g:loaded_syntastic_python_frosted_checker")
    finish
endif
let g:loaded_syntastic_python_frosted_checker=1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_python_frosted_IsAvailable()
    return executable('frosted')
endfunction

function! SyntaxCheckers_python_frosted_GetHighlightRegex(i)
    return SyntaxCheckers_python_pyflakes_GetHighlightRegex(a:i)
endfunction

function! SyntaxCheckers_python_frosted_GetLocList() dict
    let makeprg = self.makeprgBuild({})
    
    let errorformat =
        \ '%E%f:%l: could not compile,'.
        \ '%-Z%p^,'.
        \ '%E%f:%l: %m,'.
        \ '%-G%.%#'
                                        
    let loclist = SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'defaults': {'text': "Syntax error"} })
                                                                    
    for e in loclist
        let e['vcol'] = 0
    endfor
                                                                        
    return loclist
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'python',
    \ 'name': 'frosted'})

runtime! syntax_checkers/python/pyflakes.vim

let &cpo = s:save_cpo
unlet s:save_cpo
