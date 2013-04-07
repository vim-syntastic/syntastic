if exists("g:loaded_syntastic_notifier_autoloclist")
    finish
endif
let g:loaded_syntastic_notifier_autoloclist=1

"TODO: this var is a hack required for the Notifiers class. This is complicated
"because this notification type doesnt use the same option naming convention
"that Notifiers assumes
"
"i.e. it uses g:syntastic_auto_loc_list which has 3 possible values rather
"than just on or off
let g:syntastic_enable_autoloclist=1

if !exists("g:syntastic_auto_loc_list")
    let g:syntastic_auto_loc_list = 2
endif

let g:SyntasticNotifierAutoloclist = {}

" Public methods {{{1
"
function! g:SyntasticNotifierAutoloclist.New()
    let newObj = copy(self)
    return newObj
endfunction

function! g:SyntasticNotifierAutoloclist.refresh(loclist)
    call g:SyntasticNotifierAutoloclist.AutoToggle(a:loclist)
endfunction

function! g:SyntasticNotifierAutoloclist.AutoToggle(loclist)
    if a:loclist.hasErrorsOrWarningsToDisplay()
        if g:syntastic_auto_loc_list == 1
            call a:loclist.show()
        endif
    else
        if g:syntastic_auto_loc_list > 0

            "TODO: this will close the loc list window if one was opened by
            "something other than syntastic
            lclose
        endif
    endif
endfunction
