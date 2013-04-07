if exists("g:loaded_syntastic_notifiers")
    finish
endif
let g:loaded_syntastic_notifiers=1

let g:SyntasticNotifiers = {}

let s:notifier_types = ['signs', 'balloons', 'highlighting']

" Public methods {{{1

function! g:SyntasticNotifiers.New()
    let newObj = copy(self)

    let newObj._notifier = {}
    for type in s:notifier_types
        let class = substitute(type, '.*', 'SyntasticNotifier\u&', '')
        let newObj._notifier[type] = g:{class}.New()
    endfor

    let newObj._enabled_types = copy(s:notifier_types)

    return newObj
endfunction

function! g:SyntasticNotifiers.refresh(loclist)
    for type in self._enabled_types
        if ( exists('b:syntastic_enable_'.type) ? b:syntastic_enable_{type} : g:syntastic_enable_{type} )
            call self._notifier[type].refresh(a:loclist)
        endif
    endfor
endfunction

" vim: set sw=4 sts=4 et fdm=marker:
