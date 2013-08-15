"============================================================================
"File:        pep257.vim
"Description: Docstring style checking plugin for syntastic.vim
"============================================================================
"
" For details about pep257 see: https://github.com/GreenSteam/pep257

if exists("g:loaded_syntastic_python_pep257_checker")
    finish
endif
let g:loaded_syntastic_python_pep257_checker=1

function! SyntaxCheckers_python_pep257_IsAvailable()
    return executable('pep257')
endfunction

function! SyntaxCheckers_python_pep257_GetLocList()
    let makeprg = syntastic#makeprg#build({
        \ 'exe': 'pep257',
        \ 'filetype': 'python',
        \ 'subchecker': 'pep257' })

    let errorformat = '%f:%l:%c: %m'

    let loclist = SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'subtype': 'Style' })

    for n in range(len(loclist))
        let loclist[n]['type'] = loclist[n]['text'] =~? '^W' ? 'W' : 'E'
    endfor

    return loclist
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'python',
    \ 'name': 'pep257'})
