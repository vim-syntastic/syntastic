"============================================================================
"File:        html.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists("loaded_html_syntax_checker")
    finish
endif
let loaded_html_syntax_checker = 1

"bail if the user doesnt have tidy or grep installed
if !executable("tidy") || !executable("grep")
    finish
endif

" TODO: join this with xhtml.vim for DRY's sake?
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

function! SyntaxCheckers_html_GetLocList()

    "grep out the '<table> lacks "summary" attribute' since it is almost
    "always present and almost always useless
    let encopt = s:TidyEncOptByFenc()
    let makeprg="tidy ".encopt." --new-blocklevel-tags 'section, article, aside, hgroup, header, footer, nav, figure, figcaption' --new-inline-tags 'video, audio, embed, mark, progress, meter, time, ruby, rt, rp, canvas, command, details, datalist' --new-empty-tags 'wbr, keygen' -e ".shellescape(expand('%'))." 2>&1 \\| grep -v '\<table\> lacks \"summary\" attribute' \\| grep -v 'not approved by W3C'"
    let errorformat='%Wline %l column %c - Warning: %m,%Eline %l column %c - Error: %m,%-G%.%#,%-G%.%#'
    let loclist = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

    "the file name isnt in the output so stick in the buf num manually
    for i in loclist
        let i['bufnr'] = bufnr("")
    endfor

    return loclist
endfunction
