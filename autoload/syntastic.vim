if !has('balloon_eval')
    finish
endif

function! syntastic#ErrorBalloonExpr()
    if !exists('b:syntastic_balloons') | return '' | endif
    return get(b:syntastic_balloons, v:beval_lnum, '')
endfunction
