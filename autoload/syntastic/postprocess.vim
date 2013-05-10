if exists("g:loaded_syntastic_postprocess_autoload")
    finish
endif
let g:loaded_syntastic_postprocess_autoload = 1

let s:save_cpo = &cpo
set cpo&vim

function! s:compareErrorItems(a, b)
    if a:a['bufnr'] != a:b['bufnr']
        return a:a['bufnr'] - a:b['bufnr']
    elseif a:a['lnum'] != a:b['lnum']
        return a:a['lnum'] - a:b['lnum']
    elseif a:a['type'] !=? a:b['type']
        " errors take precedence over warnings
        return a:a['type'] ==? 'e' ? -1 : 1
    else
        return a:a['col'] - a:b['col']
    endif
endfunction

" natural sort
function! syntastic#postprocess#sort(errors)
    return sort(a:errors, 's:compareErrorItems')
endfunction

function syntastic#postprocess#compressWhitespace(errors)
    let llist = []

    for e in a:errors
        call add(llist, substitute(e['text'], '\s\{2,}', ' ', 'g'))
    endfor

    return llist
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set et sts=4 sw=4:
