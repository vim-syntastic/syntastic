"============================================================================
"File:        syntastic.vim
"Description: vim plugin for on the fly syntax checking
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"Version:     2.1.0
"Last Change: 14 Dec, 2011
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists("g:loaded_syntastic_plugin")
    finish
endif
let g:loaded_syntastic_plugin = 1

let s:running_windows = has("win16") || has("win32") || has("win64")

if !s:running_windows
    let s:uname = system('uname')
endif

if !exists("g:syntastic_enable_signs")
    let g:syntastic_enable_signs = 1
endif
if !has('signs')
    let g:syntastic_enable_signs = 0
endif

if !exists("g:syntastic_enable_balloons")
    let g:syntastic_enable_balloons = 1
endif
if !has('balloon_eval')
    let g:syntastic_enable_balloons = 0
endif

if !exists("g:syntastic_enable_highlighting")
    let g:syntastic_enable_highlighting = 1
endif

if !exists("g:syntastic_echo_current_error")
    let g:syntastic_echo_current_error = 1
endif

if !exists("g:syntastic_auto_loc_list")
    let g:syntastic_auto_loc_list = 2
endif

if !exists("g:syntastic_auto_jump")
    let syntastic_auto_jump=0
endif

if !exists("g:syntastic_quiet_warnings")
    let g:syntastic_quiet_warnings = 0
endif

if !exists("g:syntastic_stl_format")
    let g:syntastic_stl_format = '[Syntax: line:%F (%t)]'
endif

if !exists("g:syntastic_mode_map")
    let g:syntastic_mode_map = {}
endif

if !has_key(g:syntastic_mode_map, "mode")
    let g:syntastic_mode_map['mode'] = 'active'
endif

if !has_key(g:syntastic_mode_map, "active_filetypes")
    let g:syntastic_mode_map['active_filetypes'] = []
endif

if !has_key(g:syntastic_mode_map, "passive_filetypes")
    let g:syntastic_mode_map['passive_filetypes'] = []
endif

command! SyntasticToggleMode call s:ToggleMode()
command! SyntasticCheck call s:UpdateErrors(0) <bar> redraw!
command! Errors call s:ShowLocList()

highlight link SyntasticError SpellBad
highlight link SyntasticWarning SpellCap

augroup syntastic
    if g:syntastic_echo_current_error
        autocmd cursormoved * call s:EchoCurrentError()
    endif

    autocmd bufreadpost,bufwritepost * call s:UpdateErrors(1)
augroup END


"refresh and redraw all the error info for this buf when saving or reading
function! s:UpdateErrors(auto_invoked)
    if &buftype == 'quickfix'
        return
    endif

    if !a:auto_invoked || s:ModeMapAllowsAutoChecking()
        call s:CacheErrors()
    end

    if g:syntastic_enable_balloons
        call s:RefreshBalloons()
    endif

    if g:syntastic_enable_signs
        call s:RefreshSigns()
    endif

    if s:BufHasErrorsOrWarningsToDisplay()
        call setloclist(0, b:syntastic_loclist)
        if g:syntastic_auto_jump
            silent! ll
        endif
    elseif g:syntastic_auto_loc_list == 2
        lclose
    endif

    if g:syntastic_auto_loc_list == 1
        if s:BufHasErrorsOrWarningsToDisplay()
            call s:ShowLocList()
        else
            "TODO: this will close the loc list window if one was opened by
            "something other than syntastic
            lclose
        endif
    endif
endfunction

"detect and cache all syntax errors in this buffer
"
"depends on a function called SyntaxCheckers_{&ft}_GetLocList() existing
"elsewhere
function! s:CacheErrors()
    let b:syntastic_loclist = []

    if filereadable(expand("%"))

        "sub - for _ in filetypes otherwise we cant name syntax checker
        "functions legally for filetypes like "gentoo-metadata"
        let fts = substitute(&ft, '-', '_', 'g')

        for ft in split(fts, '\.')
            if s:Checkable(ft)
                let b:syntastic_loclist = extend(b:syntastic_loclist, SyntaxCheckers_{ft}_GetLocList())
            endif
        endfor
    endif
endfunction

"toggle the g:syntastic_mode_map['mode']
function! s:ToggleMode()
    if g:syntastic_mode_map['mode'] == "active"
        let g:syntastic_mode_map['mode'] = "passive"
    else
        let g:syntastic_mode_map['mode'] = "active"
    endif

    echo "Syntastic: " . g:syntastic_mode_map['mode'] . " mode enabled"
endfunction

"check the current filetypes against g:syntastic_mode_map to determine whether
"active mode syntax checking should be done
function! s:ModeMapAllowsAutoChecking()
    if g:syntastic_mode_map['mode'] == 'passive'

        "check at least one filetype is active
        for ft in split(&ft, '\.')
            if index(g:syntastic_mode_map['active_filetypes'], ft) != -1
                return 1
            endif
            return 0
        endfor
    else

        "check no filetypes are passive
        for ft in split(&ft, '\.')
            if index(g:syntastic_mode_map['passive_filetypes'], ft) != -1
                return 0
            endif
            return 1
        endfor
    endif
endfunction

"return true if there are cached errors/warnings for this buf
function! s:BufHasErrorsOrWarnings()
    return exists("b:syntastic_loclist") && !empty(b:syntastic_loclist)
endfunction

"return true if there are cached errors for this buf
function! s:BufHasErrors()
    return len(s:ErrorsForType('E')) > 0
endfunction

function! s:BufHasErrorsOrWarningsToDisplay()
    return s:BufHasErrors() || (!g:syntastic_quiet_warnings && s:BufHasErrorsOrWarnings())
endfunction

function! s:ErrorsForType(type)
    if !exists("b:syntastic_loclist")
        return []
    endif
    return filter(copy(b:syntastic_loclist), 'v:val["type"] ==? "' . a:type . '"')
endfunction

function s:Errors()
    return extend(s:ErrorsForType("E"), s:ErrorsForType(''))
endfunction

function s:Warnings()
    return s:ErrorsForType("W")
endfunction

if g:syntastic_enable_signs
    "use >> to display syntax errors in the sign column
    sign define SyntasticError text=>> texthl=error
    sign define SyntasticWarning text=>> texthl=todo
endif

"start counting sign ids at 5000, start here to hopefully avoid conflicting
"with any other code that places signs (not sure if this precaution is
"actually needed)
let s:first_sign_id = 5000
let s:next_sign_id = s:first_sign_id

"place signs by all syntax errs in the buffer
function s:SignErrors()
    if s:BufHasErrorsOrWarningsToDisplay()
        for i in b:syntastic_loclist
            if i['bufnr'] != bufnr("")
                continue
            endif

            let sign_type = 'SyntasticError'
            if i['type'] == 'W'
                let sign_type = 'SyntasticWarning'
            endif

            exec "sign place ". s:next_sign_id ." line=". i['lnum'] ." name=". sign_type ." file=". expand("%:p")
            call add(s:BufSignIds(), s:next_sign_id)
            let s:next_sign_id += 1
        endfor
    endif
endfunction

"remove the signs with the given ids from this buffer
function! s:RemoveSigns(ids)
    for i in a:ids
        exec "sign unplace " . i
        call remove(s:BufSignIds(), index(s:BufSignIds(), i))
    endfor
endfunction

"get all the ids of the SyntaxError signs in the buffer
function! s:BufSignIds()
    if !exists("b:syntastic_sign_ids")
        let b:syntastic_sign_ids = []
    endif
    return b:syntastic_sign_ids
endfunction

"update the error signs
function! s:RefreshSigns()
    let old_signs = copy(s:BufSignIds())
    call s:SignErrors()
    call s:RemoveSigns(old_signs)
    let s:first_sign_id = s:next_sign_id
endfunction

"display the cached errors for this buf in the location list
function! s:ShowLocList()
    if exists("b:syntastic_loclist")
        let num = winnr()
        lopen
        if num != winnr()
            wincmd p
        endif
    endif
endfunction

"remove all error highlights from the window
function! s:ClearErrorHighlights()
    for match in getmatches()
        if stridx(match['group'], 'Syntastic') == 0
            call matchdelete(match['id'])
        endif
    endfor
endfunction

"check if a syntax checker exists for the given filetype - and attempt to
"load one
function! s:Checkable(ft)
    if !exists("g:loaded_" . a:ft . "_syntax_checker")
        exec "runtime syntax_checkers/" . a:ft . ".vim"
    endif

    return exists("*SyntaxCheckers_". a:ft ."_GetLocList")
endfunction

"set up error ballons for the current set of errors
function! s:RefreshBalloons()
    let b:syntastic_balloons = {}
    if s:BufHasErrorsOrWarningsToDisplay()
        for i in b:syntastic_loclist
            let b:syntastic_balloons[i['lnum']] = i['text']
        endfor
        set beval bexpr=SyntasticErrorBalloonExpr()
    endif
endfunction

"print as much of a:msg as possible without "Press Enter" prompt appearing
function! s:WideMsg(msg)
    let old_ruler = &ruler
    let old_showcmd = &showcmd

    let msg = strpart(a:msg, 0, winwidth(0)-1)

    "This is here because it is possible for some error messages to begin with
    "\n which will cause a "press enter" prompt. I have noticed this in the
    "javascript:jshint checker and have been unable to figure out why it
    "happens
    let msg = substitute(msg, "\n", "", "g")

    set noruler noshowcmd
    redraw

    echo msg

    let &ruler=old_ruler
    let &showcmd=old_showcmd
endfunction

"echo out the first error we find for the current line in the cmd window
function! s:EchoCurrentError()
    if !exists('b:syntastic_loclist')
        return
    endif

    "If we have an error or warning at the current line, show it
    let lnum = line(".")
    for i in b:syntastic_loclist
        if lnum == i['lnum']
            let b:syntastic_echoing_error = 1
            return s:WideMsg(i['text'])
        endif
    endfor

    "Otherwise, clear the status line
    if exists("b:syntastic_echoing_error")
        echo
        unlet b:syntastic_echoing_error
    endif
endfunction

"return a string representing the state of buffer according to
"g:syntastic_stl_format
"
"return '' if no errors are cached for the buffer
function! SyntasticStatuslineFlag()
    if s:BufHasErrorsOrWarningsToDisplay()
        let errors = s:Errors()
        let warnings = s:Warnings()

        let output = g:syntastic_stl_format

        "hide stuff wrapped in %E(...) unless there are errors
        let output = substitute(output, '\C%E{\([^}]*\)}', len(errors) ? '\1' : '' , 'g')

        "hide stuff wrapped in %W(...) unless there are warnings
        let output = substitute(output, '\C%W{\([^}]*\)}', len(warnings) ? '\1' : '' , 'g')

        "hide stuff wrapped in %B(...) unless there are both errors and warnings
        let output = substitute(output, '\C%B{\([^}]*\)}', (len(warnings) && len(errors)) ? '\1' : '' , 'g')

        "sub in the total errors/warnings/both
        let output = substitute(output, '\C%w', len(warnings), 'g')
        let output = substitute(output, '\C%e', len(errors), 'g')
        let output = substitute(output, '\C%t', len(b:syntastic_loclist), 'g')

        "first error/warning line num
        let output = substitute(output, '\C%F', b:syntastic_loclist[0]['lnum'], 'g')

        "first error line num
        let output = substitute(output, '\C%fe', len(errors) ? errors[0]['lnum'] : '', 'g')

        "first warning line num
        let output = substitute(output, '\C%fw', len(warnings) ? warnings[0]['lnum'] : '', 'g')

        return output
    else
        return ''
    endif
endfunction

"A wrapper for the :lmake command. Sets up the make environment according to
"the options given, runs make, resets the environment, returns the location
"list
"
"a:options can contain the following keys:
"    'makeprg'
"    'errorformat'
"
"The corresponding options are set for the duration of the function call. They
"are set with :let, so dont escape spaces.
"
"a:options may also contain:
"   'defaults' - a dict containing default values for the returned errors
function! SyntasticMake(options)
    let old_loclist = getloclist(0)
    let old_makeprg = &makeprg
    let old_shellpipe = &shellpipe
    let old_shell = &shell
    let old_errorformat = &errorformat

    if !s:running_windows && (s:uname !~ "FreeBSD")
        "this is a hack to stop the screen needing to be ':redraw'n when
        "when :lmake is run. Otherwise the screen flickers annoyingly
        let &shellpipe='&>'
        let &shell = '/bin/bash'
    endif

    if has_key(a:options, 'makeprg')
        let &makeprg = a:options['makeprg']
    endif

    if has_key(a:options, 'errorformat')
        let &errorformat = a:options['errorformat']
    endif

    silent lmake!
    let errors = getloclist(0)

    call setloclist(0, old_loclist)
    let &makeprg = old_makeprg
    let &errorformat = old_errorformat
    let &shellpipe=old_shellpipe
    let &shell=old_shell

    if !s:running_windows && s:uname =~ "FreeBSD"
        redraw!
    endif

    if has_key(a:options, 'defaults')
        call SyntasticAddToErrors(errors, a:options['defaults'])
    endif

    return errors
endfunction

"get the error balloon for the current mouse position
function! SyntasticErrorBalloonExpr()
    if !exists('b:syntastic_balloons')
        return ''
    endif
    return get(b:syntastic_balloons, v:beval_lnum, '')
endfunction

"highlight the list of errors (a:errors) using matchadd()
"
"a:termfunc is provided to highlight errors that do not have a 'col' key (and
"hence cant be done automatically). This function must take one arg (an error
"item) and return a regex to match that item in the buffer.
"
"an optional boolean third argument can be provided to force a:termfunc to be
"used regardless of whether a 'col' key is present for the error
function! SyntasticHighlightErrors(errors, termfunc, ...)
    if !g:syntastic_enable_highlighting
        return
    endif

    call s:ClearErrorHighlights()

    let force_callback = a:0 && a:1
    for item in a:errors
        let group = item['type'] == 'E' ? 'SyntasticError' : 'SyntasticWarning'
        if item['col'] && !force_callback
            let lastcol = col([item['lnum'], '$'])
            let lcol = min([lastcol, item['col']])
            call matchadd(group, '\%'.item['lnum'].'l\%'.lcol.'c')
        else
            let term = a:termfunc(item)
            if len(term) > 0
                call matchadd(group, '\%' . item['lnum'] . 'l' . term)
            endif
        endif
    endfor
endfunction

"take a list of errors and add default values to them from a:options
function! SyntasticAddToErrors(errors, options)
    for i in range(0, len(a:errors)-1)
        for key in keys(a:options)
            if empty(a:errors[i][key])
                let a:errors[i][key] = a:options[key]
            endif
        endfor
    endfor
    return a:errors
endfunction

" vim: set et sts=4 sw=4:
