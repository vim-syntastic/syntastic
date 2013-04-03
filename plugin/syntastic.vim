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

runtime! plugin/syntastic/*.vim

let s:running_windows = has("win16") || has("win32")

if !exists("g:syntastic_enable_balloons")
    let g:syntastic_enable_balloons = 1
endif
if !has('balloon_eval')
    let g:syntastic_enable_balloons = 0
endif

if !exists("g:syntastic_enable_highlighting")
    let g:syntastic_enable_highlighting = 1
endif

" highlighting requires getmatches introduced in 7.1.040
if v:version < 701 || (v:version == 701 && !has('patch040'))
    let g:syntastic_enable_highlighting = 0
endif

if !exists("g:syntastic_echo_current_error")
    let g:syntastic_echo_current_error = 1
endif

if !exists("g:syntastic_auto_loc_list")
    let g:syntastic_auto_loc_list = 2
endif

if !exists("g:syntastic_always_populate_loc_list")
    let g:syntastic_always_populate_loc_list = 0
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

if !exists("g:syntastic_check_on_open")
    let g:syntastic_check_on_open = 0
endif

if !exists("g:syntastic_loc_list_height")
    let g:syntastic_loc_list_height = 10
endif

let s:registry = g:SyntasticRegistry.Instance()
let s:signer = g:SyntasticSigner.New()
call s:signer.SetUpSignStyles()
let s:modemap = g:SyntasticModeMap.Instance()

function! s:CompleteCheckerName(argLead, cmdLine, cursorPos)
    let checker_names = []
    for ft in s:CurrentFiletypes()
        for checker in s:registry.availableCheckersFor(ft)
            call add(checker_names, checker.name())
        endfor
    endfor
    return join(checker_names, "\n")
endfunction

command! SyntasticToggleMode call s:ToggleMode()
command! -nargs=? -complete=custom,s:CompleteCheckerName SyntasticCheck call s:UpdateErrors(0, <f-args>) <bar> call s:Redraw()
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
    autocmd BufEnter * if &bt=='quickfix' && !empty(getloclist(0)) && !bufloaded(getloclist(0)[0].bufnr) | call s:HideLocList() | endif
augroup END


"refresh and redraw all the error info for this buf when saving or reading
function! s:UpdateErrors(auto_invoked, ...)
    if s:SkipFile()
        return
    endif

    if !a:auto_invoked || s:modemap.allowsAutoChecking(&filetype)
        if a:0 >= 1
            call s:CacheErrors(a:1)
        else
            call s:CacheErrors()
        endif
    end

    if g:syntastic_enable_balloons
        call s:RefreshBalloons()
    endif

    if g:syntastic_enable_signs
        call s:signer.refreshSigns(s:LocList())
    endif

    if g:syntastic_enable_highlighting
        call s:HighlightErrors()
    endif

    let loclist = s:LocList()
    if g:syntastic_always_populate_loc_list && loclist.hasErrorsOrWarningsToDisplay()
        call setloclist(0, loclist.filteredRaw())
    endif

    if g:syntastic_auto_jump && loclist.hasErrorsOrWarningsToDisplay()
        call setloclist(0, loclist.filteredRaw())
        silent! ll
    endif

    call s:AutoToggleLocList()
endfunction

"automatically open/close the location list window depending on the users
"config and buffer error state
function! s:AutoToggleLocList()
    let loclist = s:LocList()
    if loclist.hasErrorsOrWarningsToDisplay()
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
        let b:syntastic_loclist = g:SyntasticLoclist.New([])
    endif
    return b:syntastic_loclist
endfunction

"clear the loc list for the buffer
function! s:ClearCache()
    unlet! b:syntastic_loclist
endfunction

function! s:CurrentFiletypes()
    "sub - for _ in filetypes otherwise we cant name syntax checker
    "functions legally for filetypes like "gentoo-metadata"
    let fts = substitute(&ft, '-', '_', 'g')
    return split(fts, '\.')
endfunction

"detect and cache all syntax errors in this buffer
function! s:CacheErrors(...)
    call s:ClearCache()
    let newLoclist = g:SyntasticLoclist.New([])

    if !s:SkipFile()
        for ft in s:CurrentFiletypes()

            if a:0
                let checker = s:registry.getChecker(ft, a:1)
                if !empty(checker)
                    let checkers = [checker]
                endif
            else
                let checkers = s:registry.getActiveCheckers(ft)
            endif

            for checker in checkers
                let loclist = checker.getLocList()

                if !loclist.isEmpty()
                    let newLoclist = newLoclist.extend(loclist)

                    "only get errors from one checker at a time
                    break
                endif
            endfor
        endfor
    endif

    let b:syntastic_loclist = newLoclist
endfunction

function! s:ToggleMode()
    call s:modemap.toggleMode()
    call s:ClearCache()
    call s:UpdateErrors(1)
    call s:modemap.echoMode()
endfunction

"display the cached errors for this buf in the location list
function! s:ShowLocList()
    let loclist = s:LocList()
    if loclist.hasErrorsOrWarningsToDisplay()
        call setloclist(0, loclist.filteredRaw())
        let num = winnr()
        exec "lopen " . g:syntastic_loc_list_height
        if num != winnr()
            wincmd p
        endif
    endif
endfunction

function! s:HideLocList()
    if len(filter( range(1,bufnr('$')), 'buflisted(v:val) && bufloaded(v:val)' )) == 1
        quit
    else
        lclose
    endif
endfunction

"highlight the current errors using matchadd()
"
"The function `Syntastic_{filetype}_{checker}_GetHighlightRegex` is used
"to override default highlighting.  This function must take one arg (an
"error item) and return a regex to match that item in the buffer.
function! s:HighlightErrors()
    call s:ClearErrorHighlights()
    let loclist = s:LocList()

    let fts = substitute(&ft, '-', '_', 'g')
    for ft in split(fts, '\.')

        for item in loclist.filteredRaw()
            let group = item['type'] == 'E' ? 'SyntasticError' : 'SyntasticWarning'

            if has_key(item, 'hl')
                call matchadd(group, '\%' . item['lnum'] . 'l' . item['hl'])
            elseif get(item, 'col')
                let lastcol = col([item['lnum'], '$'])
                let lcol = min([lastcol, item['col']])

                "a bug in vim can sometimes cause there to be no 'vcol' key,
                "so check for its existence
                let coltype = has_key(item, 'vcol') && item['vcol'] ? 'v' : 'c'

                call matchadd(group, '\%' . item['lnum'] . 'l\%' . lcol . coltype)
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
    let loclist = s:LocList()
    if loclist.hasErrorsOrWarningsToDisplay()
        for i in loclist.filteredRaw()
            let b:syntastic_balloons[i['lnum']] = i['text']
        endfor
        set beval bexpr=SyntasticErrorBalloonExpr()
    endif
endfunction

"print as much of a:msg as possible without "Press Enter" prompt appearing
function! s:WideMsg(msg)
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
    redraw

    echo msg

    let &ruler=old_ruler
    let &showcmd=old_showcmd
endfunction

"echo out the first error we find for the current line in the cmd window
function! s:EchoCurrentError()
    let loclist = s:LocList()
    "If we have an error or warning at the current line, show it
    let errors = loclist.filter({'lnum': line("."), "type": 'e'})
    let warnings = loclist.filter({'lnum': line("."), "type": 'w'})

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

"the script changes &shellpipe and &shell to stop the screen flicking when
"shelling out to syntax checkers. Not all OSs support the hacks though
function! s:OSSupportsShellpipeHack()
    return !s:running_windows && (s:uname() !~ "FreeBSD") && (s:uname() !~ "OpenBSD")
endfunction

function! s:IsRedrawRequiredAfterMake()
    return !s:running_windows && (s:uname() =~ "FreeBSD" || s:uname() =~ "OpenBSD")
endfunction

"Redraw in a way that doesnt make the screen flicker or leave anomalies behind.
"
"Some terminal versions of vim require `redraw!` - otherwise there can be
"random anomalies left behind.
"
"However, on some versions of gvim using `redraw!` causes the screen to
"flicker - so use redraw.
function! s:Redraw()
    if has('gui_running') || has('gui_macvim')
        redraw
    else
        redraw!
    endif
endfunction

" Skip running in special buffers
function! s:SkipFile()
    return !empty(&buftype) || !filereadable(expand('%')) || getwinvar(0, '&diff')
endfunction

function! s:uname()
    if !exists('s:uname')
        let s:uname = system('uname')
    endif
    return s:uname
endfunction

"return a string representing the state of buffer according to
"g:syntastic_stl_format
"
"return '' if no errors are cached for the buffer
function! SyntasticStatuslineFlag()
    let loclist = s:LocList()
    if loclist.hasErrorsOrWarningsToDisplay()
        let errors = loclist.errors()
        let warnings = loclist.warnings()

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
        let output = substitute(output, '\C%t', loclist.length(), 'g')

        "first error/warning line num
        let output = substitute(output, '\C%F', loclist.filteredRaw()[0]['lnum'], 'g')

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

    if s:IsRedrawRequiredAfterMake()
        call s:Redraw()
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

" vim: set et sts=4 sw=4:
