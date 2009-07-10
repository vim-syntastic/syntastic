if exists("g:loaded_syntastic_plugin")
    finish
endif
let g:loaded_syntastic_plugin = 1

let s:running_windows = has("win16") || has("win32") || has("win64")

"load all the syntax checkers
runtime! syntax_checkers/*.vim

"refresh and redraw all the error info for this buf upon saving or changing
"filetypes
autocmd filetype,bufwritepost * call s:UpdateErrors()
function! s:UpdateErrors()
    call s:CacheErrors()
    call s:ClearSigns()
    call s:SignErrors()
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
