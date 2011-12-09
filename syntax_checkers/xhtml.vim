"============================================================================
"File:        xhtml.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists("loaded_xhtml_syntax_checker")
    finish
endif
let loaded_xhtml_syntax_checker = 1

"bail if the user doesnt have tidy or grep installed
if !executable("tidy")
    finish
endif

" TODO: join this with html.vim DRY's sake?
function! s:TidyEncOptByFenc()
    let tidy_opts = {
                \'utf-8'       : '-utf8',
                \'ascii'       : '-ascii',
                \'latin1'      : '-latin1',
                \'iso-2022-jp' : '-iso-2022',
                \'cp1252'      : '-win1252',
                \'macroman'    : '-mac',
                \'utf-16le'    : '-utf16le',
                \'utf-16'      : '-utf16',
                \'big5'        : '-big5',
                \'sjis'        : '-shiftjis',
                \'cp850'       : '-ibm858',
                \}
    return get(tidy_opts, &fileencoding, '-utf8')
endfunction

function! SyntaxCheckers_xhtml_GetLocList()

    let encopt = s:TidyEncOptByFenc()
    let makeprg="tidy ".encopt." -xml -e ".shellescape(expand('%'))
    let errorformat='%Wline %l column %c - Warning: %m,%Eline %l column %c - Error: %m,%-G%.%#,%-G%.%#'
    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat, 'defaults': {'bufnr': bufnr("")} })
endfunction
