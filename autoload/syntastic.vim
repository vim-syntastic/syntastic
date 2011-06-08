
function! syntastic#ErrorBalloonExpr()
    if !exists('b:syntastic_balloons') | return '' | endif
    return get(b:syntastic_balloons, v:beval_lnum, '')
endfunction

function! syntastic#HighlightErrors(errors, termfunc)
    call clearmatches()
    for item in a:errors
        if item['col']
            let lastcol = col([item['lnum'], '$'])
            let lcol = min([lastcol, item['col']])
            call matchadd('SpellBad', '\%'.item['lnum'].'l\%'.lcol.'c')
        else
            let group = item['type'] == 'E' ? 'SpellBad' : 'SpellCap'
            let term = a:termfunc(item)
            if len(term) > 0
                call matchadd(group, '\%' . item['lnum'] . 'l' . term)
            endif
        endif
    endfor
endfunction

