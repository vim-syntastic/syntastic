"============================================================================
"File:        ghc-mod.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Anthony Carapetis <anthony.carapetis at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists('g:loaded_syntastic_haskell_ghc_mod_checker')
    finish
endif
let g:loaded_syntastic_haskell_ghc_mod_checker = 1

let s:ghc_mod_new = -1
let s:hsc2hs_map = {}

function! SyntaxCheckers_haskell_ghc_mod_IsAvailable() dict
    " We need either a Vim version that can handle NULs in system() output,
    " or a ghc-mod version that has the --boundary option.
    let s:ghc_mod_new = executable(self.getExec()) ? s:GhcModNew(self.getExec()) : -1
    return (s:ghc_mod_new >= 0) && (v:version >= 704 || s:ghc_mod_new)
endfunction

function! SyntaxCheckers_haskell_ghc_mod_GetLocList() dict
    let ext = expand('%:e')
    let makeprogOpts = {
                \ 'exe': self.getExec() . ' check' . (s:ghc_mod_new ? ' --boundary=""' : '') }

    if ext == 'hsc' && executable('hsc2hs')
        " ghc-mod cannot check .hsc files directly, so we preprocess it with
        " hsc2hs into a temporary .hs file which is then passed to ghc-mod.
        " This works because hsc2hs will generate tags that map the generated
        " file to the original .hsc file
        let makeprogOpts['fname'] = s:Hsc2Hs(expand('%'))
    endif

    let makeprg = self.makeprgBuild(makeprogOpts)

    let errorformat =
        \ '%-G%\s%#,' .
        \ '%f:%l:%c:%trror: %m,' .
        \ '%f:%l:%c:%tarning: %m,'.
        \ '%f:%l:%c: %trror: %m,' .
        \ '%f:%l:%c: %tarning: %m,' .
        \ '%f:%l:%c:%m,' .
        \ '%E%f:%l:%c:,' .
        \ '%Z%m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'postprocess': ['compressWhitespace'] })
endfunction

function! s:GhcModNew(exe)
    try
        let ghc_mod_version = filter(split(system(a:exe), '\n'), 'v:val =~# ''\m^ghc-mod version''')[0]
        let ret = syntastic#util#versionIsAtLeast(syntastic#util#parseVersion(ghc_mod_version), [2, 1, 2])
    catch /^Vim\%((\a\+)\)\=:E684/
        call syntastic#log#error("checker haskell/ghc_mod: can't parse version string (abnormal termination?)")
        let ret = -1
    endtry
    return ret
endfunction


" This function extracts all items(separated by whitespaces) under an
" option from a cabal-formatted file. It has a very crude implementation but
" sufficient for our needs
function! s:ExtractCabalSection(contents, i, section)
    let rv = []
    let contents = a:contents
    let i = a:i
    let line = contents[i]
    " Advance the line index
    let i = i + 1
    " Try match to match the section name
    let matched = matchlist(line, '\v^\ *' . a:section . '\:\ *(.*)$')
    if len(matched) > 0
        " Matched, try to extract the items in the same line as the option
        " label
        if matched[1] != ''
            let rv += split(matched[1])
        endif
        " Now continue reading lines and extracting items until another option
        " is found. We consider another option as a line that has spaces,
        " a word(no whitespaces) and a ':'
        while i < len(contents)
            let line = contents[i]
            if match(line, '\v^\ *[^: ]+\:') != -1
                break
            endif
            let rv += split(line)
            let i = i + 1
        endwhile
    endif
    return [rv, i]
endfunction


function! s:ExtractCCFlags(filename)
    let rv = []
    let contents = readfile(a:filename)
    let i = 0
    while i < len(contents)
        let [include_dirs, i] = s:ExtractCabalSection(contents, i, 'include-dirs')
        let rv += map(include_dirs, '"-I".v:val')
    endwhile
    return rv
endfunction


function! s:Hsc2Hs(file)
    if ! exists('s:hsc2hs_map[a:file]')
        let s:hsc2hs_map[a:file] = tempname() . '.hs'
    endif

    if ! exists('s:hsc2hs_flags_cache')
        if exists('g:syntastic_haskell_ghcmod_hsc2hs_flags')
            let s:hsc2hs_flags_cache = g:syntastic_haskell_ghcmod_hsc2hs_flags
        else
            let flag_list = []
            " Try to extract include directories from the .cabal/.buildinfo
            " files if they exist. These flags may be necessary to preprocess
            " the file with hsc2hs.
            let files = glob('*.cabal', 0, 1)
            if len(files) > 0 
                let flag_list += s:ExtractCCFlags(files[0])
            endif

            " If theres a .buildinfo file generated by the 'cabal configure'
            " step, extract flags from it too
            let files = glob('*.buildinfo', 0, 1)
            if len(files) > 0
                let flag_list += s:ExtractCCFlags(files[0])
            endif
            let s:hsc2hs_flags_cache = join(flag_list, ' ')
        endif
    endif

    let flags = s:hsc2hs_flags_cache

    " Invoke hsc2hs with output set to the temporary file(which is always
    " the same for a particular file)
    call system('hsc2hs -o' . s:hsc2hs_map[a:file] . ' ' . flags . ' ' . a:file)

    return s:hsc2hs_map[a:file]
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'haskell',
    \ 'name': 'ghc_mod',
    \ 'exec': 'ghc-mod'})
