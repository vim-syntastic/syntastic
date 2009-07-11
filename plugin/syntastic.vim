"============================================================================
"File:        syntastic.vim
"Description: vim plugin for on the fly syntax checking
"Maintainer:  Martin Grenfell <martin_grenfell at msn dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
"
"Syntastic does the following:
"----------------------------------------------------------------------------
"
"1. Provides a statusline flag to notify you of errors in the buffer
"2. Uses the :sign interface to point out lines with syntax errors
"3. Defines :Errors, which opens the syntax errors in quickfix window
"
"To use the above functionality, a syntax checker plugin must be present for
"the filetype in question (more about that below).
"
"
"Using the statusline flag
"----------------------------------------------------------------------------
"
"To use the statusline flag, this must appear in your &statusline setting:
"    %{SyntasticStatuslineFlag()}
"
"Something like this could be more useful:
"
"    set statusline+=%#warningmsg#
"    set statusline+=%{SyntasticStatuslineFlag()}
"    set statusline+=%*
"
"
"Implementing syntax checker plugins:
"----------------------------------------------------------------------------
"
"A syntax checker plugin is really nothing more than a single function.  You
"should define them in ~/.vim/syntax_checkers/<filetype>.vim. This is purely
"for convenience; Syntastic doesn't actually care where these functions are
"defined.
"
"A syntax checker plugin should define a function of the form:
"
"    SyntaxCheckers_<filetype>_GetQFList()
"
"The output of this function should be of the same form as the getqflist()
"function. See :help getqflist() for details.
"
"Syntastic is designed so that the syntax checker plugins can be implemented
"using vims :make facility without screwing up the users current make
"settings. To this end, the following settings are saved and restored after
"the syntax checking function is called:
"
"   * the users quickfix list
"   * &makeprg
"   * &errorformat
"
"This way, a typical syntax checker function can look like this:
"
"   function! SyntaxCheckers_ruby_GetQFList()
"       set makeprg=ruby\ -c\ %
"       set errorformat=%-GSyntax\ OK,%A%f:%l:\ syntax\ error\\,\ %m,%Z%p^,%-C%.%#
"       silent make!
"       return getqflist()
"   endfunction
"
"After this function is called, makeprg, errorformat and the quickfix list
"will be restored to their previous settings.
"
"NOTE: syntax checkers *can* piggy back off :make, but they dont *have* to. If
"&errorformat is too crazy for you then you can parse the syntax checker
"output yourself and compile it into the qflist style data structure.
"
"
"Options:
"----------------------------------------------------------------------------
"
"Use this option to tell syntastic to use the :sign interface to mark syntax
"errors
"    let g:syntastic_enable_signs=1
"
"
"============================================================================

if exists("g:loaded_syntastic_plugin")
    finish
endif
let g:loaded_syntastic_plugin = 1

let s:running_windows = has("win16") || has("win32") || has("win64")

if !exists("g:syntastic_enable_signs")
    let g:syntastic_enable_signs = 0
endif

"load all the syntax checkers
runtime! syntax_checkers/*.vim

"refresh and redraw all the error info for this buf upon saving or changing
"filetypes
autocmd filetype,bufwritepost * call s:UpdateErrors()
function! s:UpdateErrors()
    call s:CacheErrors()

    if g:syntastic_enable_signs
        call s:ClearSigns()
        call s:SignErrors()
    endif
endfunction

"detect and cache all syntax errors in this buffer
"
"depends on a function called SyntaxCheckers_{&ft}_GetQFList() existing
"elsewhere
"
"saves and restores some settings that the syntax checking function may wish
"to screw with if it uses :make!
function! s:CacheErrors()
    let b:syntastic_qflist = []

    if exists("*SyntaxCheckers_". &ft ."_GetQFList") && filereadable(expand("%"))
        let oldqfixlist = getqflist()
        let old_makeprg = &makeprg
        let old_shellpipe = &shellpipe
        let old_errorformat = &errorformat

        if !s:running_windows
            "this is a hack to stop the screen needing to be ':redraw'n when
            "when :make is run. Otherwise the screen flickers annoyingly
            let &shellpipe='&>'
        endif

        let b:syntastic_qflist =  SyntaxCheckers_{&ft}_GetQFList()

        call setqflist(oldqfixlist)
        let &makeprg = old_makeprg
        let &errorformat = old_errorformat
        let &shellpipe=old_shellpipe
    endif
endfunction

"return true if there are cached errors for this buf
function! s:BufHasErrors()
    return exists("b:syntastic_qflist") && !empty(b:syntastic_qflist)
endfunction


"use >> to display syntax errors in the sign column
sign define SyntaxError text=>> texthl=error

"start counting sign ids at 5000, start here to hopefully avoid conflicting
"wiht any other code that places signs (not sure if this precaution is
"actually needed)
let s:first_sign_id = 5000
let s:next_sign_id = s:first_sign_id

"place SyntaxError signs by all syntax errs in the buffer
function s:SignErrors()
    if s:BufHasErrors()
        for i in b:syntastic_qflist
            exec "sign place ". s:next_sign_id ." line=". i['lnum'] ." name=SyntaxError file=". expand("%:p")
            call add(s:BufSignIds(), s:next_sign_id)
            let s:next_sign_id += 1
        endfor
    endif
endfunction

"remove all SyntaxError signs in the buffer
function! s:ClearSigns()
    for i in s:BufSignIds()
        exec "sign unplace " . i
    endfor
    let b:syntastic_sign_ids = []
endfunction

"get all the ids of the SyntaxError signs in the buffer
function! s:BufSignIds()
    if !exists("b:syntastic_sign_ids")
        let b:syntastic_sign_ids = []
    endif
    return b:syntastic_sign_ids
endfunction

"display the cached errors for this buf in the quickfix list
function! s:ShowQFList()
    if exists("b:syntastic_qflist")
        call setqflist(b:syntastic_qflist)
        copen
    endif
endfunction

command Errors call s:ShowQFList()

"return [syntax:X(Y)] if syntax errors are detected in the buffer, where X is the
"line number of the first error and Y is the number of errors detected. (Y) is
"only displayed if > 1 errors are detected
"
"return '' if no errors are cached for the buffer
function! SyntasticStatuslineFlag()
    if s:BufHasErrors()
        let first_err_line = b:syntastic_qflist[0]['lnum']
        let err_count = ""
        if len(b:syntastic_qflist) > 1
            let err_count = "(" . len(b:syntastic_qflist) . ")"
        endif
        return '[syntax:' . first_err_line . err_count . ']'
    else
        return ''
    endif
endfunction

" vim: set et sts=4 sw=4:
