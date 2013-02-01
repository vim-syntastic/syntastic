if exists("g:loaded_syntastic_checker")
    finish
endif
let g:loaded_syntastic_checker=1

let g:SyntasticChecker = {}

" Public methods {{{1

function! g:SyntasticChecker.New(args)
    let newObj = copy(self)

    let newObj._filetype = a:args['filetype']
    let newObj._name = a:args['name']


    let prefix = 'SyntaxCheckers_' . newObj._filetype . '_' . newObj._name . '_'
    let newObj._locListFunc = function(prefix . 'GetLocList')
    let newObj._isAvailableFunc = function(prefix . 'IsAvailable')

    if exists('*' . prefix . 'GetHighlightRegex')
        let newObj._highlightRegexFunc = function(prefix. 'GetHighlightRegex')
    else
        let newObj._highlightRegexFunc = ''
    endif

    return newObj
endfunction

function! g:SyntasticChecker.filetype()
    return self._filetype
endfunction

function! g:SyntasticChecker.name()
    return self._name
endfunction

function! g:SyntasticChecker.getLocList()
    let list = self._locListFunc()
    return g:SyntasticLoclist.New(list)
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
