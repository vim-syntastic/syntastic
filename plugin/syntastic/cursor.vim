if exists("g:loaded_syntastic_notifier_cursor")
    finish
endif
let g:loaded_syntastic_notifier_cursor=1

let g:SyntasticNotifierCursor = {}

" Public methods {{{1

function! g:SyntasticNotifierCursor.New()
    let newObj = copy(self)
    let newObj.oldLine = -1
    return newObj
endfunction

function! g:SyntasticNotifierCursor.refresh(loclist)
    let l = line('.')
    if l == self.oldLine
        return
    endif
    let self.oldLine = l

    let messages = a:loclist.messages()
    if has_key(messages, l)
        return syntastic#util#wideMsg(messages[l])
    else
        echo
    endif
endfunction

function! g:SyntasticNotifierCursor.resetOldLine()
    let self.oldLine = -1
endfunction
