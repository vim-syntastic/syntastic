if exists("g:loaded_syntastic_checker")
    finish
endif
let g:loaded_syntastic_checker=1

let g:SyntasticChecker = {}

" Public methods {{{1

function! g:SyntasticChecker.New(args)
    let newObj = copy(self)

    let newObj._locListFunc = a:args['loclistFunc']
    let newObj._isAvailableFunc = a:args['isAvailableFunc']
    let newObj._filetype = a:args['filetype']
    let newObj._name = a:args['name']

    let newObj._highlightRegexFunc = get(a:args, 'highlightRegexFunc', '')

    return newObj
endfunction

function! g:SyntasticChecker.filetype()
    return self._filetype
endfunction

function! g:SyntasticChecker.name()
    return self._name
endfunction

function! g:SyntasticChecker.getLocList()
    return self._locListFunc()
endfunction

function! g:SyntasticChecker.getHighlightRegexFor(error)
    if empty(self._highlightRegexFunc)
        return []
    endif

    return self._highlightRegexFunc(error)
endfunction

function! g:SyntasticChecker.isAvailable()
    return self._isAvailableFunc()
endfunction

" vim: set sw=4 sts=4 et fdm=marker:
