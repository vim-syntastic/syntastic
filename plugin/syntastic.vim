"============================================================================
"File:        syntastic.vim
"Description: vim plugin for on the fly syntax checking
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"Version:     1.2.0
"Last Change: 28 Oct, 2010
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

if !exists("g:syntastic_enable_signs") || !has('signs')
    let g:syntastic_enable_signs = 0
endif

if !exists("g:syntastic_enable_balloons") || !has('balloon_eval')
    let g:syntastic_enable_balloons = 0
endif

if !exists("g:syntastic_auto_loc_list")
    let g:syntastic_auto_loc_list = 0
endif

if !exists("g:syntastic_auto_jump")
    let syntastic_auto_jump=0
endif

if !exists("g:syntastic_quiet_warnings")
    let g:syntastic_quiet_warnings = 0
endif

if !exists("g:syntastic_disabled_filetypes")
    let g:syntastic_disabled_filetypes = []
endif

if !exists("g:syntastic_stl_format")
    let g:syntastic_stl_format = '[Syntax: line:%F (%t)]'
endif

"refresh and redraw all the error info for this buf when saving or reading
autocmd bufreadpost,bufwritepost * call s:UpdateErrors()
function! s:UpdateErrors()
    if &buftype == 'quickfix'
        return
    endif
    call s:CacheErrors()

    if g:syntastic_enable_balloons && has('balloon_eval')
        let b:syntastic_balloons = {}
        for i in b:syntastic_loclist
            let b:syntastic_balloons[i['lnum']] = i['text']
        endfor
        set beval bexpr=syntastic#ErrorBalloonExpr()
    endif

    if g:syntastic_enable_signs
        call s:RefreshSigns()
    endif

    if s:BufHasErrorsOrWarningsToDisplay()
        call setloclist(0, b:syntastic_loclist)
        if g:syntastic_auto_jump
            silent!ll
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
        for ft in split(&ft, '\.')
            if s:Checkable(ft)
                let b:syntastic_loclist = extend(b:syntastic_loclist, SyntaxCheckers_{ft}_GetLocList())
            endif
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

command Errors call s:ShowLocList()

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

    return errors
endfunction

function! s:Checkable(ft)
    if !exists("g:loaded_" . a:ft . "_syntax_checker")
        exec "runtime syntax_checkers/" . a:ft . ".vim"
    endif

    return exists("*SyntaxCheckers_". a:ft ."_GetLocList") &&
                \ index(g:syntastic_disabled_filetypes, a:ft) == -1
endfunction

command! -nargs=? SyntasticEnable call s:Enable(<f-args>)
command! -nargs=? SyntasticDisable call s:Disable(<f-args>)

"disable syntax checking for the given filetype (defaulting to current ft)
function! s:Disable(...)
    let ft = a:0 ? a:1 : &filetype

    if !empty(ft) && index(g:syntastic_disabled_filetypes, ft) == -1
        call add(g:syntastic_disabled_filetypes, ft)
    endif

    "will cause existing errors to be cleared
    call s:UpdateErrors()
endfunction

"enable syntax checking for the given filetype (defaulting to current ft)
function! s:Enable(...)
    let ft = a:0 ? a:1 : &filetype

    let i = index(g:syntastic_disabled_filetypes, ft)
    if i != -1
        call remove(g:syntastic_disabled_filetypes, i)
    endif

    if !&modified
        call s:UpdateErrors()
        redraw!
    else
        echom "Syntasic: enabled for the '" . ft . "' filetype. :write out to update errors"
    endif
endfunction

" vim: set et sts=4 sw=4:
