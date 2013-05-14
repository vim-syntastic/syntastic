if exists("g:loaded_syntastic_loclist")
    finish
endif
let g:loaded_syntastic_loclist = 1

let g:SyntasticLoclist = {}

" Public methods {{{1

function! g:SyntasticLoclist.New(rawLoclist)
    let newObj = copy(self)
    let newObj._quietWarnings = g:syntastic_quiet_warnings

    let llist = copy(a:rawLoclist)
    let llist = filter(llist, 'v:val["valid"] == 1')

    for e in llist
        if empty(e['type'])
            let e['type'] = 'E'
        endif
    endfor

    let newObj._rawLoclist = llist
    let newObj._hasErrorsOrWarningsToDisplay = -1

    return newObj
endfunction

function! g:SyntasticLoclist.current()
    if !exists("b:syntastic_loclist")
        let b:syntastic_loclist = g:SyntasticLoclist.New([])
    endif
    return b:syntastic_loclist
endfunction

function! g:SyntasticLoclist.extend(other)
    let list = self.toRaw()
    call extend(list, a:other.toRaw())
    return g:SyntasticLoclist.New(list)
endfunction

function! g:SyntasticLoclist.toRaw()
    return copy(self._rawLoclist)
endfunction

function! g:SyntasticLoclist.filteredRaw()
    return copy(self._quietWarnings ? self.errors() : self._rawLoclist)
endfunction

function! g:SyntasticLoclist.quietWarnings()
    return self._quietWarnings
endfunction

function! g:SyntasticLoclist.isEmpty()
    return empty(self._rawLoclist)
endfunction

function! g:SyntasticLoclist.length()
    return len(self._rawLoclist)
endfunction

function! g:SyntasticLoclist.hasErrorsOrWarningsToDisplay()
    if self._hasErrorsOrWarningsToDisplay >= 0
        return self._hasErrorsOrWarningsToDisplay
    endif
    let self._hasErrorsOrWarningsToDisplay = empty(self._rawLoclist) ? 0 : (!self._quietWarnings || len(self.errors()))
    return self._hasErrorsOrWarningsToDisplay
endfunction

function! g:SyntasticLoclist.errors()
    if !exists("self._cachedErrors")
        let self._cachedErrors = self.filter({'type': "E"})
    endif
    return self._cachedErrors
endfunction

function! g:SyntasticLoclist.warnings()
    if !exists("self._cachedWarnings")
        let self._cachedWarnings = self.filter({'type': "W"})
    endif
    return self._cachedWarnings
endfunction

" cache used by EchoCurrentError()
function! g:SyntasticLoclist.messages()
    if !exists("self._cachedMessages")
        let self._cachedMessages = {}

        for e in self.errors()
            if !has_key(self._cachedMessages, e['lnum'])
                let self._cachedMessages[e['lnum']] = e['text']
            endif
        endfor

        if !self._quietWarnings
            for e in self.warnings()
                if !has_key(self._cachedMessages, e['lnum'])
                    let self._cachedMessages[e['lnum']] = e['text']
                endif
            endfor
        endif
    endif

    return self._cachedMessages
endfunction

"Filter the list and return new native loclist
"e.g.
"  .filter({'bufnr': 10, 'type': 'e'})
"
"would return all errors for buffer 10.
"
"Note that all comparisons are done with ==?
function! g:SyntasticLoclist.filter(filters)
    let rv = []

    for error in self._rawLoclist

        let passes_filters = 1
        for key in keys(a:filters)
            if error[key] !=? a:filters[key]
                let passes_filters = 0
                break
            endif
        endfor

        if passes_filters
            call add(rv, error)
        endif
    endfor
    return rv
endfunction

"display the cached errors for this buf in the location list
function! g:SyntasticLoclist.show()
    if self.hasErrorsOrWarningsToDisplay()
        call setloclist(0, self.filteredRaw())
        let num = winnr()
        exec "lopen " . g:syntastic_loc_list_height
        if num != winnr()
            wincmd p
        endif
    endif
endfunction

" Non-method functions {{{1

function! g:SyntasticLoclistHide()
    silent! lclose
endfunction

" vim: set sw=4 sts=4 et fdm=marker:
