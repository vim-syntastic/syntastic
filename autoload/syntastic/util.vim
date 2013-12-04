if exists("g:loaded_syntastic_util_autoload")
    finish
endif
let g:loaded_syntastic_util_autoload = 1

let s:save_cpo = &cpo
set cpo&vim

if !exists("g:syntastic_delayed_redraws")
    let g:syntastic_delayed_redraws = 0
endif

let s:redraw_delayed = 0
let s:redraw_full = 0

if g:syntastic_delayed_redraws
    " CursorHold / CursorHoldI events are triggered if user doesn't press a
    " key for &updatetime ms.  We change it only if current value is the default
    " value, that is 4000 ms.
    if &updatetime == 4000
        let &updatetime = 500
    endif

    augroup syntastic
        autocmd CursorHold,CursorHoldI * call syntastic#util#redrawHandler()
    augroup END
endif

" Public functions {{{1

function! syntastic#util#isRunningWindows()
    return has('win16') || has('win32') || has('win64')
endfunction

function! syntastic#util#DevNull()
    if syntastic#util#isRunningWindows()
        return 'NUL'
    endif
    return '/dev/null'
endfunction

" Get directory separator
function! syntastic#util#Slash() abort
    return !exists("+shellslash") || &shellslash ? '/' : '\'
endfunction

"search the first 5 lines of the file for a magic number and return a map
"containing the args and the executable
"
"e.g.
"
"#!/usr/bin/perl -f -bar
"
"returns
"
"{'exe': '/usr/bin/perl', 'args': ['-f', '-bar']}
function! syntastic#util#parseShebang()
    for lnum in range(1,5)
        let line = getline(lnum)

        if line =~ '^#!'
            let exe = matchstr(line, '\m^#!\s*\zs[^ \t]*')
            let args = split(matchstr(line, '\m^#!\s*[^ \t]*\zs.*'))
            return {'exe': exe, 'args': args}
        endif
    endfor

    return {'exe': '', 'args': []}
endfunction

" Parse a version string.  Return an array of version components.
function! syntastic#util#parseVersion(version)
    return split(matchstr( a:version, '\v^\D*\zs\d+(\.\d+)+\ze' ), '\m\.')
endfunction

" Run 'command' in a shell and parse output as a version string.
" Returns an array of version components.
function! syntastic#util#getVersion(command)
    return syntastic#util#parseVersion(system(a:command))
endfunction

" Verify that the 'installed' version is at least the 'required' version.
"
" 'installed' and 'required' must be arrays. If they have different lengths,
" the "missing" elements will be assumed to be 0 for the purposes of checking.
"
" See http://semver.org for info about version numbers.
function! syntastic#util#versionIsAtLeast(installed, required)
    for index in range(max([len(a:installed), len(a:required)]))
        if len(a:installed) <= index
            let installed_element = 0
        else
            let installed_element = a:installed[index]
        endif
        if len(a:required) <= index
            let required_element = 0
        else
            let required_element = a:required[index]
        endif
        if installed_element != required_element
            return installed_element > required_element
        endif
    endfor
    " Everything matched, so it is at least the required version.
    return 1
endfunction

"print as much of a:msg as possible without "Press Enter" prompt appearing
function! syntastic#util#wideMsg(msg)
    let old_ruler = &ruler
    let old_showcmd = &showcmd

    "convert tabs to spaces so that the tabs count towards the window width
    "as the proper amount of characters
    let msg = substitute(a:msg, "\t", repeat(" ", &tabstop), "g")
    let msg = strpart(msg, 0, winwidth(0)-1)

    "This is here because it is possible for some error messages to begin with
    "\n which will cause a "press enter" prompt. I have noticed this in the
    "javascript:jshint checker and have been unable to figure out why it
    "happens
    let msg = substitute(msg, "\n", "", "g")

    set noruler noshowcmd
    call syntastic#util#redraw(0)

    echo msg

    let &ruler=old_ruler
    let &showcmd=old_showcmd
endfunction

" Check whether a buffer is loaded, listed, and not hidden
function! syntastic#util#bufIsActive(buffer)
    " convert to number, or hell breaks loose
    let buf = str2nr(a:buffer)

    if !bufloaded(buf) || !buflisted(buf)
        return 0
    endif

    " get rid of hidden buffers
    for tab in range(1, tabpagenr('$'))
        if index(tabpagebuflist(tab), buf) >= 0
            return 1
        endif
    endfor

    return 0
endfunction

" start in directory a:where and walk up the parent folders until it
" finds a file matching a:what; return path to that file
function! syntastic#util#findInParent(what, where)
    let here = fnamemodify(a:where, ':p')

    let root = syntastic#util#Slash()
    if syntastic#util#isRunningWindows() && here[1] == ':'
        " The drive letter is an ever-green source of fun.  That's because
        " we don't care about running syntastic on Amiga these days. ;)
        let root = fnamemodify(root, ':p')
        let root = here[0] . root[1:]
    endif

    while !empty(here)
        let p = split(globpath(here, a:what), '\n')

        if !empty(p)
            return fnamemodify(p[0], ':p')
        elseif here ==? root
            break
        endif

        " we use ':h:h' rather than ':h' since ':p' adds a trailing '/'
        " if 'here' is a directory
        let here = fnamemodify(here, ':p:h:h')
    endwhile

    return ''
endfunction

" Returns unique elements in a list
function! syntastic#util#unique(list)
    let seen = {}
    let uniques = []
    for e in a:list
        if !has_key(seen, e)
            let seen[e] = 1
            call add(uniques, e)
        endif
    endfor
    return uniques
endfunction

" A less noisy shellescape()
function! syntastic#util#shescape(string)
    return a:string =~ '\m^[A-Za-z0-9_/.-]\+$' ? a:string : shellescape(a:string)
endfunction

" A less noisy shellescape(expand())
function! syntastic#util#shexpand(string)
    return syntastic#util#shescape(expand(a:string))
endfunction

" decode XML entities
function! syntastic#util#decodeXMLEntities(string)
    let str = a:string
    let str = substitute(str, '\m&lt;', '<', 'g')
    let str = substitute(str, '\m&gt;', '>', 'g')
    let str = substitute(str, '\m&quot;', '"', 'g')
    let str = substitute(str, '\m&apos;', "'", 'g')
    let str = substitute(str, '\m&amp;', '\&', 'g')
    return str
endfunction

" On older Vim versions calling redraw while a popup is visible can make
" Vim segfault, so move redraws to a CursorHold / CursorHoldI handler.
function! syntastic#util#redraw(full)
    if !g:syntastic_delayed_redraws || !pumvisible()
        call s:doRedraw(a:full)
        let s:redraw_delayed = 0
        let s:redraw_full = 0
    else
        let s:redraw_delayed = 1
        let s:redraw_full = s:redraw_full || a:full
    endif
endfunction

function! syntastic#util#redrawHandler()
    if s:redraw_delayed && !pumvisible()
        call s:doRedraw(s:redraw_full)
        let s:redraw_delayed = 0
        let s:redraw_full = 0
    endif
endfunction

" Private functions {{{1

"Redraw in a way that doesnt make the screen flicker or leave anomalies behind.
"
"Some terminal versions of vim require `redraw!` - otherwise there can be
"random anomalies left behind.
"
"However, on some versions of gvim using `redraw!` causes the screen to
"flicker - so use redraw.
function! s:doRedraw(full)
    if a:full
        redraw!
    else
        redraw
    endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set et sts=4 sw=4 fdm=marker:
