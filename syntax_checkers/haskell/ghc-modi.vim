"============================================================================
"File:        ghc-modi.vim
"Description: Syntax checking plugin for syntastic.vim
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists('g:loaded_syntastic_haskell_ghc_modi_checker')
    finish
endif
let g:loaded_syntastic_haskell_ghc_modi_checker = 1

let s:save_cpo = &cpo
set cpo&vim

" Map where the key is the root directory and the value is the process object.
let s:ghc_modi_procs = {}

" Map where the key is the filename and the value is the root directory.
" This is essentially just a cache of the output of `ghc-mod root`.
let s:ghc_modi_roots = {}

function! SyntaxCheckers_haskell_ghc_modi_GetLocList() dict
    let ghcmodi_prog = self.makeprgBuild({ 'exe': self.getExecEscaped() . ' --boundary="\n "' })

    let fullfile = expand("%:p")

    if has_key(s:ghc_modi_roots, fullfile)
        let root = s:ghc_modi_roots[fullfile]
        call syntastic#log#debug(1, "found root " . root . " for file " . fullfile)
    else
        let root = system("cd '" . expand("%:p:h") . "'; ghc-mod root")
        let s:ghc_modi_roots[fullfile] = root
        call syntastic#log#debug(1, "computed root " . root . " for file " . fullfile)
    endif

    if has_key(s:ghc_modi_procs, root)
        let proc = s:ghc_modi_procs[root]
        call syntastic#log#debug(1, "found proc")
    else
        let olddir = getcwd()
        exec "lcd " . root
        let proc = vimproc#popen2(ghcmodi_prog)
        exec "lcd " . olddir
        let s:ghc_modi_procs[root] = proc
        call syntastic#log#debug(1, "executing ghcmodi_prog")
    endif

    call proc.stdin.write("check " . fullfile . "\n")

    let found_end = 0
    let cmd_output = ""

    while found_end == 0
        for line in proc.stdout.read_lines()
            call syntastic#log#debug(1, "ghc-modi read: " . line)
            if line == "OK"
                let found_end = 1
            elseif line =~ "^NG "
                let cmd_output .= line . "\n"
                let found_end = 1
            elseif len(line) > 0
                let cmd_output .= line . "\n"
            endif
        endfor
    endwhile

    call syntastic#log#debug(1, "ghc-modi produced: " . cmd_output)

    "Check for program status
    if proc.checkpid()[0] !=# "run"
        unlet s:ghc_modi_procs[root]
        call syntastic#log#debug(1, "ghc-modi stopped")
    endif

    let errorformat =
        \ '%f:%l:%c:%m,' .
        \ '\ %m'

    return SyntasticMake({
        \ 'makeoutput': cmd_output,
        \ 'errorformat': errorformat,
        \ 'returns': [0] })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'haskell',
    \ 'name': 'ghc_modi',
    \ 'exec': 'ghc-modi' })

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sts=4 sw=4:
