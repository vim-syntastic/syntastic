"============================================================================
"File:        tidy.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
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

let s:ignore_html_errors = [
                \ "<table> lacks \"summary\" attribute",
                \ "not approved by W3C",
                \ "attribute \"placeholder\"",
                \ "<meta> proprietary attribute \"charset\"",
                \ "<meta> lacks \"content\" attribute",
                \ "inserting \"type\" attribute",
                \ "proprietary attribute \"data-"
                \]

function! s:ValidateError(text)
    let valid = 0
    for i in s:ignore_html_errors
        if stridx(a:text, i) != -1
            let valid = 1
            break
        endif
    endfor
    return valid
endfunction

function! SyntaxCheckers_html_GetLocList()
    let encopt = s:TidyEncOptByFenc()
    let makeprg="tidy ".encopt." --new-blocklevel-tags ".shellescape('section, article, aside, hgroup, header, footer, nav, figure, figcaption')." --new-inline-tags ".shellescape('video, audio, embed, mark, progress, meter, time, ruby, rt, rp, canvas, command, details, datalist')." --new-empty-tags ".shellescape('wbr, keygen')." -e ".shellescape(expand('%'))." 2>&1"
    let errorformat='%Wline %l column %c - Warning: %m,%Eline %l column %c - Error: %m,%-G%.%#,%-G%.%#'
    let loclist = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

    " process loclist since we need to add some info and filter out valid HTML5
    " from the errors
    let n = len(loclist) - 1
    let bufnum = bufnr("")
    while n >= 0
        let i = loclist[n]
        " filter out valid HTML5
        if s:ValidateError(i['text']) == 1
            unlet loclist[n]
        else
            "the file name isnt in the output so stick in the buf num manually
            let i['bufnr'] = bufnum
        endif
        let n -= 1
    endwhile

    return loclist
endfunction
