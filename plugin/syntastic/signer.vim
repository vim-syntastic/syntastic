if exists("g:loaded_syntastic_signer")
    finish
endif
let g:loaded_syntastic_signer=1

if !exists("g:syntastic_enable_signs")
    let g:syntastic_enable_signs = 1
endif

if !exists("g:syntastic_error_symbol")
    let g:syntastic_error_symbol = '>>'
endif

if !exists("g:syntastic_warning_symbol")
    let g:syntastic_warning_symbol = '>>'
endif

if !exists("g:syntastic_style_error_symbol")
    let g:syntastic_style_error_symbol = 'S>'
endif

if !exists("g:syntastic_style_warning_symbol")
    let g:syntastic_style_warning_symbol = 'S>'
endif

if !has('signs')
    let g:syntastic_enable_signs = 0
endif


"start counting sign ids at 5000, start here to hopefully avoid conflicting
"with any other code that places signs (not sure if this precaution is
"actually needed)
let s:first_sign_id = 5000
let s:next_sign_id = s:first_sign_id

let g:SyntasticSigner = {}

"Public methods {{{1
function! g:SyntasticSigner.New()
    let newObj = copy(self)
    return newObj
endfunction

function! g:SyntasticSigner.SetUpSignStyles()
    if g:syntastic_enable_signs
        if !hlexists('SyntasticErrorSign')
            highlight link SyntasticErrorSign error
        endif
        if !hlexists('SyntasticWarningSign')
            highlight link SyntasticWarningSign todo
        endif
        if !hlexists('SyntasticStyleErrorSign')
            highlight link SyntasticStyleErrorSign SyntasticErrorSign
        endif
        if !hlexists('SyntasticStyleWarningSign')
            highlight link SyntasticStyleWarningSign SyntasticWarningSign
        endif
        if !hlexists('SyntasticStyleErrorLine')
            highlight link SyntasticStyleErrorLine SyntasticErrorLine
        endif
        if !hlexists('SyntasticStyleWarningLine')
            highlight link SyntasticStyleWarningLine SyntasticWarningLine
        endif

        "define the signs used to display syntax and style errors/warns
        exe 'sign define SyntasticError text='.g:syntastic_error_symbol.' texthl=SyntasticErrorSign linehl=SyntasticErrorLine'
        exe 'sign define SyntasticWarning text='.g:syntastic_warning_symbol.' texthl=SyntasticWarningSign linehl=SyntasticWarningLine'
        exe 'sign define SyntasticStyleError text='.g:syntastic_style_error_symbol.' texthl=SyntasticStyleErrorSign linehl=SyntasticStyleErrorLine'
        exe 'sign define SyntasticStyleWarning text='.g:syntastic_style_warning_symbol.' texthl=SyntasticStyleWarningSign linehl=SyntasticStyleWarningLine'
    endif
endfunction

"update the error signs
function! g:SyntasticSigner.refreshSigns(loclist)
    let old_signs = copy(self._bufSignIds())
    call self._signErrors(a:loclist)
    call self._removeSigns(old_signs)
    let s:first_sign_id = s:next_sign_id
endfunction

"Private methods {{{1
"
"place signs by all syntax errs in the buffer
function! g:SyntasticSigner._signErrors(loclist)
    let loclist = a:loclist
    if loclist.hasErrorsOrWarningsToDisplay()

        let errors = loclist.filter({'bufnr': bufnr('')})
        for i in errors
            let sign_severity = 'Error'
            let sign_subtype = ''
            if has_key(i,'subtype')
                let sign_subtype = i['subtype']
            endif
            if i['type'] ==? 'w'
                let sign_severity = 'Warning'
            endif
            let sign_type = 'Syntastic' . sign_subtype . sign_severity

            if !self._warningMasksError(i, errors)
                exec "sign place ". s:next_sign_id ." line=". i['lnum'] ." name=". sign_type ." file=". expand("%:p")
                call add(self._bufSignIds(), s:next_sign_id)
                let s:next_sign_id += 1
            endif
        endfor
    endif
endfunction

"return true if the given error item is a warning that, if signed, would
"potentially mask an error if displayed at the same time
function! g:SyntasticSigner._warningMasksError(error, llist)
    if a:error['type'] !=? 'w'
        return 0
    endif

    let loclist = g:SyntasticLoclist.New(a:llist)
    return len(loclist.filter({ 'type': "E", 'lnum': a:error['lnum'] })) > 0
endfunction

"remove the signs with the given ids from this buffer
function! g:SyntasticSigner._removeSigns(ids)
    for i in a:ids
        exec "sign unplace " . i
        call remove(self._bufSignIds(), index(self._bufSignIds(), i))
    endfor
endfunction

"get all the ids of the SyntaxError signs in the buffer
function! g:SyntasticSigner._bufSignIds()
    if !exists("b:syntastic_sign_ids")
        let b:syntastic_sign_ids = []
    endif
    return b:syntastic_sign_ids
endfunction

" vim: set sw=4 sts=4 et fdm=marker:
