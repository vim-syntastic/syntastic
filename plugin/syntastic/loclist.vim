if exists("g:loaded_syntastic_loclist")
    finish
endif
let g:loaded_syntastic_list=1

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

    return newObj
endfunction

function! g:SyntasticLoclist.extend(other)
    let list = self.toRaw()
    call extend(list, a:other.toRaw())
    return g:SyntasticLoclist.New(list)
endfunction

function! g:SyntasticLoclist.toRaw()
    return copy(self._rawLoclist)
endfunction

function! g:SyntasticLoclist.isEmpty()
    return empty(self._rawLoclist)
endfunction

function! g:SyntasticLoclist.length()
    return len(self._rawLoclist)
endfunction

function! g:SyntasticLoclist.hasErrorsOrWarningsToDisplay()
    if empty(self._rawLoclist)
        return 0
    endif
    return len(self.errors()) || !self._quietWarnings
endfunction

function! g:SyntasticLoclist.errors()
    if !exists("self._cachedErrors")
        let self._cachedErrors = self.filter({'type': "E"})
    endif
    return self._cachedErrors
endfunction

function! SyntasticLoclist.warnings()
    if !exists("self._cachedWarnings")
        let self._cachedWarnings = self.filter({'type': "W"})
    endif
    return self._cachedWarnings
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
