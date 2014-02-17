if exists("g:loaded_syntastic_registry")
    finish
endif
let g:loaded_syntastic_registry = 1

" Initialisation {{{1

let s:defaultCheckers = {
        \ 'actionscript':['mxmlc'],
        \ 'ada':         ['gcc'],
        \ 'applescript': ['osacompile'],
        \ 'asciidoc':    ['asciidoc'],
        \ 'asm':         ['gcc'],
        \ 'bemhtml':     ['bemhtmllint'],
        \ 'c':           ['gcc'],
        \ 'chef':        ['foodcritic'],
        \ 'co':          ['coco'],
        \ 'cobol':       ['cobc'],
        \ 'coffee':      ['coffee', 'coffeelint'],
        \ 'coq':         ['coqtop'],
        \ 'cpp':         ['gcc'],
        \ 'cs':          ['mcs'],
        \ 'css':         ['csslint', 'phpcs'],
        \ 'cucumber':    ['cucumber'],
        \ 'cuda':        ['nvcc'],
        \ 'd':           ['dmd'],
        \ 'dart':        ['dartanalyzer'],
        \ 'docbk':       ['xmllint'],
        \ 'dustjs':      ['swiffer'],
        \ 'elixir':      ['elixir'],
        \ 'erlang':      ['escript'],
        \ 'eruby':       ['ruby'],
        \ 'fortran':     ['gfortran'],
        \ 'glsl':        ['cgc'],
        \ 'go':          ['go'],
        \ 'haml':        ['haml'],
        \ 'handlebars':  ['handlebars'],
        \ 'haskell':     ['ghc_mod', 'hdevtools', 'hlint'],
        \ 'haxe':        ['haxe'],
        \ 'hss':         ['hss'],
        \ 'html':        ['tidy'],
        \ 'java':        ['javac'],
        \ 'javascript':  ['jshint', 'jslint'],
        \ 'json':        ['jsonlint', 'jsonval'],
        \ 'less':        ['lessc'],
        \ 'lex':         ['flex'],
        \ 'limbo':       ['limbo'],
        \ 'lisp':        ['clisp'],
        \ 'llvm':        ['llvm'],
        \ 'lua':         ['luac'],
        \ 'matlab':      ['mlint'],
        \ 'nasm':        ['nasm'],
        \ 'nroff':       ['mandoc'],
        \ 'objc':        ['gcc'],
        \ 'objcpp':      ['gcc'],
        \ 'ocaml':       ['camlp4o'],
        \ 'perl':        ['perl', 'perlcritic'],
        \ 'php':         ['php', 'phpcs', 'phpmd'],
        \ 'po':          ['msgfmt'],
        \ 'pod':         ['podchecker'],
        \ 'puppet':      ['puppet', 'puppetlint'],
        \ 'python':      ['python', 'flake8', 'pylint'],
        \ 'racket':      ['racket'],
        \ 'rst':         ['rst2pseudoxml'],
        \ 'ruby':        ['mri'],
        \ 'rust':        ['rustc'],
        \ 'sass':        ['sass'],
        \ 'scala':       ['fsc', 'scalac'],
        \ 'scss':        ['sass', 'scss_lint'],
        \ 'sh':          ['sh', 'shellcheck'],
        \ 'slim':        ['slimrb'],
        \ 'tcl':         ['nagelfar'],
        \ 'tex':         ['lacheck', 'chktex'],
        \ 'texinfo':     ['makeinfo'],
        \ 'text':        ['atdtool'],
        \ 'twig':        ['twiglint'],
        \ 'typescript':  ['tsc'],
        \ 'vala':        ['valac'],
        \ 'verilog':     ['verilator'],
        \ 'vhdl':        ['ghdl'],
        \ 'vim':         ['vimlint'],
        \ 'xhtml':       ['tidy'],
        \ 'xml':         ['xmllint'],
        \ 'xslt':        ['xmllint'],
        \ 'yacc':        ['bison'],
        \ 'yaml':        ['jsyaml'],
        \ 'z80':         ['z80syntaxchecker'],
        \ 'zpt':         ['zptlint'],
        \ 'zsh':         ['zsh', 'shellcheck']
    \ }

let s:defaultFiletypeMap = {
        \ 'gentoo-metadata': 'xml',
        \ 'lhaskell': 'haskell',
        \ 'litcoffee': 'coffee'
    \ }

let g:SyntasticRegistry = {}

" }}}1

" Public methods {{{1

" TODO: Handling of filetype aliases: all public methods take aliases as
" parameters, all private methods take normalized filetypes.  Public methods
" are thus supposed to normalize filetypes before calling private methods.

function! g:SyntasticRegistry.Instance()
    if !exists('s:SyntasticRegistryInstance')
        let s:SyntasticRegistryInstance = copy(self)
        let s:SyntasticRegistryInstance._checkerRaw = {}
        let s:SyntasticRegistryInstance._checkerMap = {}
    endif

    return s:SyntasticRegistryInstance
endfunction

function! g:SyntasticRegistry.CreateAndRegisterChecker(args)
    let checker = g:SyntasticChecker.New(a:args)
    let registry = g:SyntasticRegistry.Instance()
    call registry._registerChecker(checker)
endfunction

function! g:SyntasticRegistry.isCheckable(ftalias)
    let ft = s:normaliseFiletype(a:ftalias)
    call self._loadCheckers(ft)
    return !empty(self._checkerMap[ft])
endfunction

function! g:SyntasticRegistry.getCheckersMap(ftalias)
    let ft = s:normaliseFiletype(a:ftalias)
    call self._loadCheckers(ft)
    return self._checkerMap[ft]
endfunction

function! g:SyntasticRegistry.getCheckers(ftalias, list)
    let checkers_map = self.getCheckersMap(a:ftalias)
    if empty(checkers_map)
        return []
    endif

    let ft = s:normaliseFiletype(a:ftalias)
    call self._checkDeprecation(ft)

    let ft_list =
        \ !empty(a:list) ? a:list :
        \ exists('b:syntastic_checkers') ? b:syntastic_checkers :
        \ exists('g:syntastic_' . ft . '_checkers') ? g:syntastic_{ft}_checkers :
        \ get(s:defaultCheckers, ft, [])

    return !empty(ft_list) ?
        \ self._filterCheckersByName(checkers_map, ft_list) : [checkers_map[keys(checkers_map)[0]]]
endfunction

function! g:SyntasticRegistry.getKnownFiletypes()
    let types = keys(s:defaultCheckers)

    call extend(types, keys(s:defaultFiletypeMap))

    if exists('g:syntastic_filetype_map')
        call extend(types, keys(g:syntastic_filetype_map))
    endif

    if exists('g:syntastic_extra_filetypes') && type(g:syntastic_extra_filetypes) == type([])
        call extend(types, g:syntastic_extra_filetypes)
    endif

    return syntastic#util#unique(types)
endfunction

function! g:SyntasticRegistry.echoInfoFor(ftalias_list)
    echomsg "Syntastic info for filetype: " . join(a:ftalias_list, '.')

    if len(a:ftalias_list) != 1
        let available = []
        let active = []

        for ftalias in a:ftalias_list
            let ft = s:normaliseFiletype(ftalias)
            call extend(available, map( keys(self.getCheckersMap(ftalias)), 'ft . "/" . v:val' ))
            call extend(active, map( self.getCheckers(ftalias, []), 'ft . "/" . v:val.getName()' ))
        endfor
    else
        let ft = a:ftalias_list[0]
        let available = keys(self.getCheckersMap(ft))
        let active = map(self.getCheckers(ft, []), 'v:val.getName()')
    endif

    echomsg "Available checker(s): " . join(sort(available))
    echomsg "Currently enabled checker(s): " . join(active)
endfunction

" }}}1

" Private methods {{{1

function! g:SyntasticRegistry._registerChecker(checker) abort
    let ft = a:checker.getFiletype()

    if !has_key(self._checkerRaw, ft)
        let self._checkerRaw[ft] = []
        let self._checkerMap[ft] = {}
    endif

    call self._validateUniqueName(a:checker)

    let name = a:checker.getName()
    call add(self._checkerRaw[ft], name)

    if a:checker.isAvailable()
        let self._checkerMap[ft][name] = a:checker
    endif
endfunction

function! g:SyntasticRegistry._filterCheckersByName(checkers_map, list)
    return filter( map(copy(a:list), 'get(a:checkers_map, v:val, {})'), '!empty(v:val)' )
endfunction

function! g:SyntasticRegistry._loadCheckers(filetype)
    if has_key(self._checkerRaw, a:filetype)
        return
    endif

    execute "runtime! syntax_checkers/" . a:filetype . "/*.vim"

    if !has_key(self._checkerRaw, a:filetype)
        let self._checkerRaw[a:filetype] = []
        let self._checkerMap[a:filetype] = {}
    endif
endfunction

function! g:SyntasticRegistry._validateUniqueName(checker) abort
    let ft = a:checker.getFiletype()
    let name = a:checker.getName()
    if index(self._checkerRaw[ft], name) > -1
        throw 'Syntastic: Duplicate syntax checker name: ' . ft . '/' . name
    endif
endfunction

" Check for obsolete variable g:syntastic_<filetype>_checker
function! g:SyntasticRegistry._checkDeprecation(filetype)
    if exists('g:syntastic_' . a:filetype . '_checker') && !exists('g:syntastic_' . a:filetype . '_checkers')
        let g:syntastic_{a:filetype}_checkers = [g:syntastic_{a:filetype}_checker]
        call syntastic#log#deprecationWarn('variable g:syntastic_' . a:filetype . '_checker is deprecated')
    endif
endfunction

" }}}1

" Private functions {{{1

"resolve filetype aliases, and replace - with _ otherwise we cant name
"syntax checker functions legally for filetypes like "gentoo-metadata"
function! s:normaliseFiletype(ftalias)
    let ft = get(s:defaultFiletypeMap, a:ftalias, a:ftalias)
    let ft = get(g:syntastic_filetype_map, ft, ft)
    let ft = substitute(ft, '\m-', '_', 'g')
    return ft
endfunction

" }}}1

" vim: set sw=4 sts=4 et fdm=marker:
