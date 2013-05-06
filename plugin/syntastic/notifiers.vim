if exists("g:loaded_syntastic_notifiers")
    finish
endif
let g:loaded_syntastic_notifiers = 1

let g:SyntasticNotifiers = {}

let s:notifier_types = ['signs', 'balloons', 'highlighting', 'cursor', 'autoloclist']

" Public methods {{{1

function! g:SyntasticNotifiers.New()
    let newObj = copy(self)

    let newObj._notifier = {}
    for type in s:notifier_types
        let class = substitute(type, '.*', 'Syntastic\u&Notifier', '')
        let newObj._notifier[type] = g:{class}.New()
    endfor

    let newObj._enabled_types = copy(s:notifier_types)

    return newObj
endfunction

function! g:SyntasticNotifiers.refresh(loclist)
    for type in self._enabled_types
        let class = substitute(type, '.*', 'Syntastic\u&Notifier', '')
        if !has_key(g:{class}, 'enabled') || self._notifier[type].enabled()
            call self._notifier[type].refresh(a:loclist)
        endif
    endfor
endfunction

function! g:SyntasticNotifiers.reset(loclist)
    for type in self._enabled_types
        let class = substitute(type, '.*', 'Syntastic\u&Notifier', '')
        if has_key(g:{class}, 'reset') && (!has_key(g:{class}, 'enabled') || self._notifier[type].enabled())
            call self._notifier[type].reset(a:loclist)
        endif
    endfor
endfunction

" vim: set sw=4 sts=4 et fdm=marker:
