"============================================================================
"File:        shellcheck.vim
"Description: Shell script syntax/style checking plugin for syntastic.vim
"============================================================================

if exists("g:loaded_syntastic_sh_shellcheck_checker")
    finish
endif
let g:loaded_syntastic_sh_shellcheck_checker = 1

function! SyntaxCheckers_sh_shellcheck_IsAvailable()
    return executable('jsoncheck')
endfunction

function! SyntaxCheckers_sh_shellcheck_Preprocess(json)
    " A hat tip to Mark Weber for this trick
    " http://stackoverflow.com/a/19105763
    let errors = eval(join(a:json, ''))

    call filter(errors, 'v:val["level"] =~? ''\v^(error|warning|style)$''')
    return map(errors, 'v:val["level"][0] . ":" . v:val["line"] . ":" . v:val["column"] . ":" . v:val["message"]')
endfunction

function! SyntaxCheckers_sh_shellcheck_GetLocList()
    let makeprg = 'jsoncheck <' . syntastic#util#shexpand('%')

    let errorformat = '%t:%l:%v:%m'

    let loclist = SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'preprocess': 'SyntaxCheckers_sh_shellcheck_Preprocess',
        \ 'defaults': {'bufnr': bufnr("")},
        \ 'returns': [0] })

    for e in loclist
        if e['type'] ==? 's'
            let e['type'] = 'w'
            let e['subtype'] = 'Style'
        endif
    endfor

    return loclist
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'sh',
    \ 'name': 'shellcheck' })
