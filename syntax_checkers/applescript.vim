"==============================================================================
"       FileName: applescript.vim
"           Desc: Syntax checking plugin for syntastic.vim
"         Author: Zhao Cai
"          Email: caizhaoff@gmail.com
"        Version: 0.1
"   Date Created: Thu 09 Sep 2011 10:30:09 AM EST 
"  Last Modified: Fri 09 Dec 2011 10:32:04 AM EST 
"
"        History: 0.1 - working, but it will run the script everytime to check
"                 syntax. Should use osacompile but strangely it does not give
"                 errors.
"
"                 0.1.1 - switch to osacompile, it gives less errors compared
"                 with osascript.
"
"        License: This program is free software. It comes without any
"        warranty, to the extent permitted by applicable law. You can
"        redistribute it and/or modify it under the terms of the Do What The
"        Fuck You Want To Public License, Version 2, as published by Sam
"        Hocevar.  See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists("loaded_applescript_syntax_checker")
    finish
endif
let loaded_applescript_syntax_checker = 1

"bail if the user doesnt have osacompile installed
if !executable("osacompile")
    finish
endif

if !exists("g:syntastic_applescript_tempfile")
    echohl WarningMsg
    echom "set g:syntastic_applescript_tempfile = /path/to/file.scpt is recommanded."
    echohl NONE

    let s:osacompile = 'osacompile -o ' . shellescape(expand('%:p:r') . '.scpt')
else
    if &verbose > 1 && filereadable(g:syntastic_applescript_tempfile)
        echom g:syntastic_applescript_tempfile . ' exists. Make sure it is OK to overwrite!'
    endif
    let s:osacompile = 'osacompile -o ' . g:syntastic_applescript_tempfile
endif

function! SyntaxCheckers_applescript_GetLocList()
    let makeprg = s:osacompile .' '. shellescape(expand('%'))
    let errorformat = '%f:%l:%m'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction
