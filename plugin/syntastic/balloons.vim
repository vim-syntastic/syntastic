if exists("g:loaded_syntastic_notifier_balloons")
    finish
endif
let g:loaded_syntastic_notifier_balloons=1

if !exists("g:syntastic_enable_balloons")
    let g:syntastic_enable_balloons = 1
endif

if !has('balloon_eval')
    let g:syntastic_enable_balloons = 0
endif

let g:SyntasticNotifierBalloons = {}

" Public methods {{{1

function! g:SyntasticNotifierBalloons.New()
    let newObj = copy(self)
    return newObj
endfunction

function! g:SyntasticNotifierBalloons.enabled()
    return exists('b:syntastic_enable_balloons') ? b:syntastic_enable_balloons : g:syntastic_enable_balloons
endfunction

" Update the error balloons
function! g:SyntasticNotifierBalloons.refresh(loclist)
    let b:syntastic_balloons = {}
    if a:loclist.hasErrorsOrWarningsToDisplay()
        for i in a:loclist.filteredRaw()
            if has_key(b:syntastic_balloons, i['lnum'])
                let b:syntastic_balloons[i['lnum']] .= "\n" . i['text']
            else
                let b:syntastic_balloons[i['lnum']] = i['text']
            endif
        endfor
        set beval bexpr=SyntasticNotifierBalloonsExpr()
    endif
endfunction

" Private functions {{{1

function! SyntasticNotifierBalloonsExpr()
    if !exists('b:syntastic_balloons')
        return ''
    endif
    return get(b:syntastic_balloons, v:beval_lnum, '')
endfunction

" vim: set sw=4 sts=4 et fdm=marker:
