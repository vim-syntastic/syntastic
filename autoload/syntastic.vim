
function! syntastic#ErrorBalloonExpr()
    if !exists('b:syntastic_balloons') | return '' | endif
    return get(b:syntastic_balloons, v:beval_lnum, '')
endfunction

function! syntastic#HighlightErrors(errors, termfunc, ...)
    call clearmatches()
    let forcecb = a:0 && a:1
    for item in a:errors
        let group = item['type'] == 'E' ? 'SpellBad' : 'SpellCap'
        if item['col'] && !forcecb
            let lastcol = col([item['lnum'], '$'])
            let lcol = min([lastcol, item['col']])
            call matchadd(group, '\%'.item['lnum'].'l\%'.lcol.'c')
        else
            let term = a:termfunc(item)
            if len(term) > 0
                call matchadd(group, '\%' . item['lnum'] . 'l' . term)
            endif
        endif
    endfor
endfunction

