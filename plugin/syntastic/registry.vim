if exists("g:loaded_syntastic_registry")
    finish
endif
let g:loaded_syntastic_registry=1

let g:SyntasticRegistry = {}

" Public methods {{{1

function! g:SyntasticRegistry.Instance()
    if !exists('s:SyntasticRegistryInstance')
        let s:SyntasticRegistryInstance = copy(self)
        let s:SyntasticRegistryInstance._checkerMap = {}
    endif

    return s:SyntasticRegistryInstance
endfunction

function! g:SyntasticRegistry.CreateAndRegisterChecker(args)
    let checker = g:SyntasticChecker.New(a:args)
    let registry = g:SyntasticRegistry.Instance()
    call registry.registerChecker(checker)
endfunction

function! g:SyntasticRegistry.registerChecker(checker)
    let ft = a:checker.filetype()

    if !has_key(self._checkerMap, ft)
        let self._checkerMap[ft] = []
    endif

    call add(self._checkerMap[ft], a:checker)
endfunction

function! g:SyntasticRegistry.checkable(filetype)
    return !empty(self.getActiveCheckers(a:filetype))
endfunction

function! g:SyntasticRegistry.getActiveCheckers(filetype)
    let allCheckers = copy(self._checkersFor(a:filetype))

    "only use checkers the user has specified
    if exists("g:syntastic_" . a:filetype . "_checkers")
        let whitelist = g:syntastic_{a:filetype}_checkers
        call filter(allCheckers, "index(whitelist, v:val.name()) != -1")
    endif

    "only use available checkers
    return filter(allCheckers, "v:val.isAvailable()")
endfunction


" Private methods {{{1

function! g:SyntasticRegistry._checkersFor(filetype)
    call self._loadCheckers(a:filetype)
    if empty(self._checkerMap[a:filetype])
        return []
    endif

    return self._checkerMap[a:filetype]
endfunction

function! g:SyntasticRegistry._loadCheckers(filetype)
    if self._haveLoadedCheckers(a:filetype)
        return
    endif

    exec "runtime! syntax_checkers/" . a:filetype . "/*.vim"

    if !has_key(self._checkerMap, a:filetype)
        let self._checkerMap[a:filetype] = []
    endif
endfunction

function! g:SyntasticRegistry._haveLoadedCheckers(filetype)
    return has_key(self._checkerMap, a:filetype)
endfunction

" vim: set sw=4 sts=4 et fdm=marker:
