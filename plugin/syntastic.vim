"============================================================================
"File:        syntastic.vim
"Description: vim plugin for on the fly syntax checking
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"Version:     2.3.0
"Last Change: 16 Feb, 2012
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

let s:running_windows = has("win16") || has("win32")

if !exists("g:syntastic_enable_signs")
    let g:syntastic_enable_signs = 1
endif

if !exists("g:syntastic_error_symbol")
    let g:syntastic_error_symbol = '>>'
endif

if !exists("g:syntastic_warning_symbol")
    let g:syntastic_warning_symbol = '>>'
endif

if !exists("g:syntastic_style_error_symbol")
    let g:syntastic_style_error_symbol = 'S>'
endif

if !exists("g:syntastic_style_warning_symbol")
    let g:syntastic_style_warning_symbol = 'S>'
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

if !exists("g:syntastic_check_on_open")
    let g:syntastic_check_on_open = 0
endif

if !exists("g:syntastic_loc_list_height")
    let g:syntastic_loc_list_height = 10
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

    autocmd BufReadPost * if g:syntastic_check_on_open | call s:UpdateErrors(1) | endif
    autocmd BufWritePost * call s:UpdateErrors(1)

    autocmd BufWinEnter * if empty(&bt) | call s:AutoToggleLocList() | endif
    autocmd BufWinLeave * if empty(&bt) | lclose | endif
augroup END


"refresh and redraw all the error info for this buf when saving or reading
function! s:UpdateErrors(auto_invoked)
    if !empty(&buftype)
        return
    endif

    if !a:auto_invoked || s:ModeMapAllowsAutoChecking()
        call s:CacheErrors()
    end

    call setloclist(0, s:LocList())

    if g:syntastic_enable_balloons
        call s:RefreshBalloons()
    endif

    if g:syntastic_enable_signs
        call s:RefreshSigns()
    endif

    if g:syntastic_enable_highlighting
        call s:HightlightErrors()
    endif

    if g:syntastic_auto_jump && s:BufHasErrorsOrWarningsToDisplay()
        silent! ll
    endif

    call s:AutoToggleLocList()
endfunction

"automatically open/close the location list window depending on the users
"config and buffer error state
function! s:AutoToggleLocList()
    if s:BufHasErrorsOrWarningsToDisplay()
        if g:syntastic_auto_loc_list == 1
            call s:ShowLocList()
        endif
    else
        if g:syntastic_auto_loc_list > 0

            "TODO: this will close the loc list window if one was opened by
            "something other than syntastic
            lclose
        endif
    endif
endfunction

"lazy init the loc list for the current buffer
function! s:LocList()
    if !exists("b:syntastic_loclist")
        let b:syntastic_loclist = []
    endif
    return b:syntastic_loclist
endfunction

"clear the loc list for the buffer
function! s:ClearCache()
    let b:syntastic_loclist = []
    unlet! b:syntastic_errors
    unlet! b:syntastic_warnings
endfunction

"detect and cache all syntax errors in this buffer
"
"depends on a function called SyntaxCheckers_{&ft}_GetLocList() existing
"elsewhere
function! s:CacheErrors()
    call s:ClearCache()

    if filereadable(expand("%"))

        "sub - for _ in filetypes otherwise we cant name syntax checker
        "functions legally for filetypes like "gentoo-metadata"
        let fts = substitute(&ft, '-', '_', 'g')
        for ft in split(fts, '\.')
            if SyntasticCheckable(ft)
                let errors = SyntaxCheckers_{ft}_GetLocList()
                "keep only lines that effectively match an error/warning
                let errors = s:FilterLocList({'valid': 1}, errors)
                "make errors have type "E" by default
                call SyntasticAddToErrors(errors, {'type': 'E'})
                call extend(s:LocList(), errors)
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

    call s:ClearCache()
    call s:UpdateErrors(1)

    echo "Syntastic: " . g:syntastic_mode_map['mode'] . " mode enabled"
endfunction

"check the current filetypes against g:syntastic_mode_map to determine whether
"active mode syntax checking should be done
function! s:ModeMapAllowsAutoChecking()
    let fts = split(&ft, '\.')

    if g:syntastic_mode_map['mode'] == 'passive'
        "check at least one filetype is active
        let actives = g:syntastic_mode_map["active_filetypes"]
        return !empty(filter(fts, 'index(actives, v:val) != -1'))
    else
        "check no filetypes are passive
        let passives = g:syntastic_mode_map["passive_filetypes"]
        return empty(filter(fts, 'index(passives, v:val) != -1'))
    endif
endfunction

function! s:BufHasErrorsOrWarningsToDisplay()
    if empty(s:LocList())
        return 0
    endif
    return len(s:Errors()) || !g:syntastic_quiet_warnings
endfunction

function! s:Errors()
    if !exists("b:syntastic_errors")
        let b:syntastic_errors = s:FilterLocList({'type': "E"})
    endif
    return b:syntastic_errors
endfunction

function! s:Warnings()
    if !exists("b:syntastic_warnings")
        let b:syntastic_warnings = s:FilterLocList({'type': "W"})
    endif
    return b:syntastic_warnings
endfunction

"Filter a loc list (defaults to s:LocList()) by a:filters
"e.g.
"  s:FilterLocList({'bufnr': 10, 'type': 'e'})
"
"would return all errors in s:LocList() for buffer 10.
"
"Note that all comparisons are done with ==?
function! s:FilterLocList(filters, ...)
    let llist = a:0 ? a:1 : s:LocList()

    let rv = []

    for error in llist

        let passes_filters = 1
        for key in keys(a:filters)
            if error[key] !=? a:filters[key]
                let passes_filters = 0
                break
            endif
        endfor

        if passes_filters
            call add(rv, error)
        endif
    endfor
    return rv
endfunction

if g:syntastic_enable_signs
    "define the signs used to display syntax and style errors/warns
    exe 'sign define SyntasticError text='.g:syntastic_error_symbol.' texthl=error'
    exe 'sign define SyntasticWarning text='.g:syntastic_warning_symbol.' texthl=todo'
    exe 'sign define SyntasticStyleError text='.g:syntastic_style_error_symbol.' texthl=error'
    exe 'sign define SyntasticStyleWarning text='.g:syntastic_style_warning_symbol.' texthl=todo'
endif

"start counting sign ids at 5000, start here to hopefully avoid conflicting
"with any other code that places signs (not sure if this precaution is
"actually needed)
let s:first_sign_id = 5000
let s:next_sign_id = s:first_sign_id

"place signs by all syntax errs in the buffer
function! s:SignErrors()
    if s:BufHasErrorsOrWarningsToDisplay()

        let errors = s:FilterLocList({'bufnr': bufnr('')})
        for i in errors
            let sign_severity = 'Error'
            let sign_subtype = ''
            if has_key(i,'subtype')
                let sign_subtype = i['subtype']
            endif
            if i['type'] ==? 'w'
                let sign_severity = 'Warning'
            endif
            let sign_type = 'Syntastic' . sign_subtype . sign_severity

            if !s:WarningMasksError(i, errors)
                exec "sign place ". s:next_sign_id ." line=". i['lnum'] ." name=". sign_type ." file=". expand("%:p")
                call add(s:BufSignIds(), s:next_sign_id)
                let s:next_sign_id += 1
            endif
        endfor
    endif
endfunction

"return true if the given error item is a warning that, if signed, would
"potentially mask an error if displayed at the same time
function! s:WarningMasksError(error, llist)
    if a:error['type'] !=? 'w'
        return 0
    endif

    return len(s:FilterLocList({ 'type': "E", 'lnum': a:error['lnum'] }, a:llist)) > 0
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
    if !empty(s:LocList())
        call setloclist(0, s:LocList())
        let num = winnr()
        exec "lopen " . g:syntastic_loc_list_height
        if num != winnr()
            wincmd p
        endif
    endif
endfunction

"highlight the current errors using matchadd()
"
"The function `Syntastic_{&ft}_GetHighlightRegex` is used to get the regex to
"highlight errors that do not have a 'col' key (and hence cant be done
"automatically). This function must take one arg (an error item) and return a
"regex to match that item in the buffer.
"
"If the 'force_highlight_callback' key is set for an error item, then invoke
"the callback even if it can be highlighted automatically.
function! s:HightlightErrors()
    call s:ClearErrorHighlights()

    let fts = substitute(&ft, '-', '_', 'g')
    for ft in split(fts, '\.')

        for item in s:LocList()

            let force_callback = has_key(item, 'force_highlight_callback') && item['force_highlight_callback']

            let group = item['type'] == 'E' ? 'SyntasticError' : 'SyntasticWarning'
            if get( item, 'col' ) && !force_callback
                let lastcol = col([item['lnum'], '$'])
                let lcol = min([lastcol, item['col']])
                call matchadd(group, '\%'.item['lnum'].'l\%'.lcol.'c')
            else

                if exists("*SyntaxCheckers_". ft ."_GetHighlightRegex")
                    let term = SyntaxCheckers_{ft}_GetHighlightRegex(item)
                    if len(term) > 0
                        call matchadd(group, '\%' . item['lnum'] . 'l' . term)
                    endif
                endif
            endif
        endfor
    endfor
endfunction

"remove all error highlights from the window
function! s:ClearErrorHighlights()
    for match in getmatches()
        if stridx(match['group'], 'Syntastic') == 0
            call matchdelete(match['id'])
        endif
    endfor
endfunction

"set up error ballons for the current set of errors
function! s:RefreshBalloons()
    let b:syntastic_balloons = {}
    if s:BufHasErrorsOrWarningsToDisplay()
        for i in s:LocList()
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
    "If we have an error or warning at the current line, show it
    let errors = s:FilterLocList({'lnum': line("."), "type": 'e'})
    let warnings = s:FilterLocList({'lnum': line("."), "type": 'w'})

    let b:syntastic_echoing_error = len(errors) || len(warnings)
    if len(errors)
        return s:WideMsg(errors[0]['text'])
    endif
    if len(warnings)
        return s:WideMsg(warnings[0]['text'])
    endif

    "Otherwise, clear the status line
    if b:syntastic_echoing_error
        echo
        let b:syntastic_echoing_error = 0
    endif
endfunction

"load the chosen checker for the current filetype - useful for filetypes like
"javascript that have more than one syntax checker
function! s:LoadChecker(checker, ft)
    exec "runtime syntax_checkers/" . a:ft . "/" . a:checker . ".vim"
endfunction

"the script changes &shellpipe and &shell to stop the screen flicking when
"shelling out to syntax checkers. Not all OSs support the hacks though
function! s:OSSupportsShellpipeHack()
    if !exists("s:os_supports_shellpipe_hack")
        let s:os_supports_shellpipe_hack = !s:running_windows && (s:uname() !~ "FreeBSD") && (s:uname() !~ "OpenBSD")
    endif
    return s:os_supports_shellpipe_hack
endfunction

function! s:uname()
    if !exists('s:uname')
        let s:uname = system('uname')
    endif
    return s:uname
endfunction

"check if a syntax checker exists for the given filetype - and attempt to
"load one
function! SyntasticCheckable(ft)
    if !exists("g:loaded_" . a:ft . "_syntax_checker")
        exec "runtime syntax_checkers/" . a:ft . ".vim"
    endif

    return exists("*SyntaxCheckers_". a:ft ."_GetLocList")
endfunction

"the args must be arrays of the form [major, minor, macro]
function SyntasticIsVersionAtLeast(installed, required)
    if a:installed[0] != a:required[0]
        return a:installed[0] > a:required[0]
    endif

    if a:installed[1] != a:required[1]
        return a:installed[1] > a:required[1]
    endif

    return a:installed[2] >= a:required[2]
endfunction

"return a string representing the state of buffer according to
"g:syntastic_stl_format
"
"return '' if no errors are cached for the buffer
function! SyntasticStatuslineFlag()
    if s:BufHasErrorsOrWarningsToDisplay()
        let errors = s:Errors()
        let warnings = s:Warnings()

        let num_errors = len(errors)
        let num_warnings = len(warnings)

        let output = g:syntastic_stl_format

        "hide stuff wrapped in %E(...) unless there are errors
        let output = substitute(output, '\C%E{\([^}]*\)}', num_errors ? '\1' : '' , 'g')

        "hide stuff wrapped in %W(...) unless there are warnings
        let output = substitute(output, '\C%W{\([^}]*\)}', num_warnings ? '\1' : '' , 'g')

        "hide stuff wrapped in %B(...) unless there are both errors and warnings
        let output = substitute(output, '\C%B{\([^}]*\)}', (num_warnings && num_errors) ? '\1' : '' , 'g')

        "sub in the total errors/warnings/both
        let output = substitute(output, '\C%w', num_warnings, 'g')
        let output = substitute(output, '\C%e', num_errors, 'g')
        let output = substitute(output, '\C%t', len(s:LocList()), 'g')

        "first error/warning line num
        let output = substitute(output, '\C%F', s:LocList()[0]['lnum'], 'g')

        "first error line num
        let output = substitute(output, '\C%fe', num_errors ? errors[0]['lnum'] : '', 'g')

        "first warning line num
        let output = substitute(output, '\C%fw', num_warnings ? warnings[0]['lnum'] : '', 'g')

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
"   'subtype' - all errors will be assigned the given subtype
function! SyntasticMake(options)
    let old_loclist = getloclist(0)
    let old_makeprg = &l:makeprg
    let old_shellpipe = &shellpipe
    let old_shell = &shell
    let old_errorformat = &l:errorformat

    if s:OSSupportsShellpipeHack()
        "this is a hack to stop the screen needing to be ':redraw'n when
        "when :lmake is run. Otherwise the screen flickers annoyingly
        let &shellpipe='&>'
        let &shell = '/bin/bash'
    endif

    if has_key(a:options, 'makeprg')
        let &l:makeprg = a:options['makeprg']
    endif

    if has_key(a:options, 'errorformat')
        let &l:errorformat = a:options['errorformat']
    endif

    silent lmake!
    let errors = getloclist(0)

    call setloclist(0, old_loclist)
    let &l:makeprg = old_makeprg
    let &l:errorformat = old_errorformat
    let &shellpipe=old_shellpipe
    let &shell=old_shell

    if s:OSSupportsShellpipeHack()
        redraw!
    endif

    if has_key(a:options, 'defaults')
        call SyntasticAddToErrors(errors, a:options['defaults'])
    endif

    " Add subtype info if present.
    if has_key(a:options, 'subtype')
        call SyntasticAddToErrors(errors, {'subtype': a:options['subtype']})
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

"take a list of errors and add default values to them from a:options
function! SyntasticAddToErrors(errors, options)
    for i in range(0, len(a:errors)-1)
        for key in keys(a:options)
            if !has_key(a:errors[i], key) || empty(a:errors[i][key])
                let a:errors[i][key] = a:options[key]
            endif
        endfor
    endfor
    return a:errors
endfunction

"take a list of syntax checkers for the current filetype and load the right
"one based on the global settings and checker executable availabity
"
"a:checkers should be a list of syntax checker names. These names are assumed
"to be the names of the vim syntax checker files that should be sourced, as
"well as the names of the actual syntax checker executables. The checkers
"should be listed in order of default preference.
"
"a:ft should be the filetype for the checkers being loaded
"
"if a option called 'g:syntastic_{a:ft}_checker' exists then attempt to
"load the checker that it points to
function! SyntasticLoadChecker(checkers, ft)
    let opt_name = "g:syntastic_" . a:ft . "_checker"

    if exists(opt_name)
        let opt_val = {opt_name}
        if index(a:checkers, opt_val) != -1
            call s:LoadChecker(opt_val, a:ft)
        else
            echoerr &ft . " syntax not supported or not installed."
        endif
    else
        for checker in a:checkers
            if executable(checker)
                return s:LoadChecker(checker, a:ft)
            endif
        endfor
    endif
endfunction

" vim: set et sts=4 sw=4:
