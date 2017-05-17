"============================================================================
"File:        hdevtools.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Anthony Carapetis <anthony.carapetis at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists('g:loaded_syntastic_haskell_hdevtools_checker')
    finish
endif
let g:loaded_syntastic_haskell_hdevtools_checker = 1

if !exists('g:syntastic_hdevtools_config_file')
    let g:syntastic_hdevtools_config_file = '.syntastic_hdevtools_config'
endif

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_haskell_hdevtools_GetLocList() dict
    if !exists('g:syntastic_haskell_hdevtools_args') && exists('g:hdevtools_options')
        call syntastic#log#oneTimeWarn('variable g:hdevtools_options is deprecated, ' .
            \ 'please use g:syntastic_haskell_hdevtools_args instead')
        let g:syntastic_haskell_hdevtools_args = g:hdevtools_options
    endif

    let buf = bufnr('')
    let makeprg = self.makeprgBuild({
        \ 'exe_after': 'check',
        \ 'args_before' : s:ReadConfig(g:syntastic_hdevtools_config_file),
        \ 'fname': syntastic#util#shescape(fnamemodify(bufname(buf), ':p')) })

    let errorformat =
        \ '%-Z %#,'.
        \ '%W%\m%f:%l:%v%\%%(-%\d%\+%\)%\=: Warning: %m,'.
        \ '%W%\m%f:%l:%v%\%%(-%\d%\+%\)%\=: Warning:,'.
        \ '%E%\m%f:%l:%v%\%%(-%\d%\+%\)%\=: %m,'.
        \ '%E%>%\m%f:%l:%v%\%%(-%\d%\+%\)%\=:,'.
        \ '%+C  %#%m,'.
        \ '%W%>%\m%f:%l:%v%\%%(-%\d%\+%\)%\=:,'.
        \ '%+C  %#%tarning: %m,'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'defaults': {'vcol': 1},
        \ 'postprocess': ['compressWhitespace'] })
endfunction

" read additional compiler flags from the given configuration file
" the file format and its parsing mechanism is inspired by clang_complete
function! s:ReadConfig(file) abort " {{{2
    call syntastic#log#debug(g:_SYNTASTIC_DEBUG_CHECKERS, 'ReadConfig: looking for', a:file)

    " search upwards from the current file's directory
    let config = syntastic#util#findFileInParent(a:file, expand('%:p:h', 1))
    if config ==# ''
        call syntastic#log#debug(g:_SYNTASTIC_DEBUG_CHECKERS, 'ReadConfig: file not found')
        return ''
    endif
    call syntastic#log#debug(g:_SYNTASTIC_DEBUG_CHECKERS, 'ReadConfig: config file:', config)
    if !filereadable(config)
        call syntastic#log#debug(g:_SYNTASTIC_DEBUG_CHECKERS, 'ReadConfig: file unreadable')
        return ''
    endif

    " convert filename into absolute path
    let filepath = fnamemodify(config, ':p:h')

    " try to read config file
    try
        let lines = readfile(config)
    catch /\m^Vim\%((\a\+)\)\=:E48[45]/
        call syntastic#log#debug(g:_SYNTASTIC_DEBUG_CHECKERS, 'ReadConfig: error reading file')
        return ''
    endtry

    " filter out empty lines and comments
    call filter(lines, 'v:val !~# ''\v^(\s*#|$)''')

    " remove leading and trailing spaces
    call map(lines, 'substitute(v:val, ''\m^\s\+'', "", "")')
    call map(lines, 'substitute(v:val, ''\m\s\+$'', "", "")')

    map(lines, 'syntastic#util#shescape(v:val)')
    return lines
endfunction " }}}2

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'haskell',
    \ 'name': 'hdevtools'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
