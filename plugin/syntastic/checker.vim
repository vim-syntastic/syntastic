if exists("g:loaded_syntastic_checker")
    finish
endif
let g:loaded_syntastic_checker = 1

let g:SyntasticChecker = {}

" Public methods {{{1

function! g:SyntasticChecker.New(args)
    let newObj = copy(self)

    let newObj._filetype = a:args['filetype']
    let newObj._name = a:args['name']
    let newObj._exec = get(a:args, 'exec', newObj._name)
    let newObj._makeprgFunc = function('SyntasticCheckerMakeprgBuild')

    if has_key(a:args, 'redirect')
        let [filetype, name] = split(a:args['redirect'], '/')
        let prefix = 'SyntaxCheckers_' . filetype . '_' . name . '_'
    else
        let prefix = 'SyntaxCheckers_' . newObj._filetype . '_' . newObj._name . '_'
    endif

    let newObj._locListFunc = function(prefix . 'GetLocList')

    if exists('*' . prefix . 'IsAvailable')
        let newObj._isAvailableFunc = function(prefix . 'IsAvailable')
    else
        let newObj._isAvailableFunc = function('SyntasticCheckerIsAvailableDefault')
    endif

    if exists('*' . prefix . 'GetHighlightRegex')
        let newObj._highlightRegexFunc = function(prefix . 'GetHighlightRegex')
    else
        let newObj._highlightRegexFunc = ''
    endif

    return newObj
endfunction

function! g:SyntasticChecker.getFiletype()
    return self._filetype
endfunction

function! g:SyntasticChecker.getName()
    return self._name
endfunction

function! g:SyntasticChecker.getExec()
    if exists('g:syntastic_' . self._filetype . '_' . self._name . '_exec')
        return expand(g:syntastic_{self._filetype}_{self._name}_exec)
    endif

    return self._exec
endfunction

function! g:SyntasticChecker.getLocList()
    try
        let list = self._locListFunc()
        call syntastic#log#debug(g:SyntasticDebugTrace,
            \ 'getLocList: checker ' . self._filetype . '/' . self._name . ' returned ' . v:shell_error)
    catch /\m\C^Syntastic: checker error$/
        let list = []
        call syntastic#log#error('checker ' . self._filetype . '/' . self._name . ' returned abnormal status ' . v:shell_error)
    endtry
    call self._populateHighlightRegexes(list)
    return g:SyntasticLoclist.New(list)
endfunction

function! g:SyntasticChecker.getLocListRaw()
    return self._locListFunc()
endfunction

function! g:SyntasticChecker.getHighlightRegexFor(error)
    return empty(self._highlightRegexFunc) ? [] : self._highlightRegexFunc(a:error)
endfunction

function! g:SyntasticChecker.makeprgBuild(opts)
    return self._makeprgFunc(a:opts)
endfunction

function! g:SyntasticChecker.isAvailable()
    return self._isAvailableFunc()
endfunction

" Private methods {{{1

function! g:SyntasticChecker._populateHighlightRegexes(errors)
    let list = a:errors
    if !empty(self._highlightRegexFunc)
        for e in list
            if e['valid']
                let term = self._highlightRegexFunc(e)
                if len(term) > 0
                    let e['hl'] = term
                endif
            endif
        endfor
    endif
    return list
endfunction

" Non-method functions
function! SyntasticCheckerIsAvailableDefault() dict
    return executable(self.getExec())
endfunction

function! SyntasticCheckerMakeprgBuild(opts) dict
    let builder = g:SyntasticMakeprgBuilder.New(
                \ get(a:opts, 'checker', self),
                \ get(a:opts, 'exe', ''),
                \ get(a:opts, 'args', ''),
                \ get(a:opts, 'fname', ''),
                \ get(a:opts, 'post_args', ''),
                \ get(a:opts, 'tail', '') )

    return builder.makeprg()
endfunction

" vim: set sw=4 sts=4 et fdm=marker:
