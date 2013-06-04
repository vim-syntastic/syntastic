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
"
" Checker option:
"
" - g:syntastic_html_tidy_ignore_errors (list; default: [])
"   list of errors to ignore

if exists("g:loaded_syntastic_html_tidy_checker")
    finish
endif
let g:loaded_syntastic_html_tidy_checker = 1

if !exists('g:syntastic_html_tidy_ignore_errors')
    let g:syntastic_html_tidy_ignore_errors = []
endif

function! SyntaxCheckers_html_tidy_IsAvailable()
    return executable('tidy')
endfunction

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
                \'cp932'       : '-shiftjis',
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
                \ "proprietary attribute \"data-",
                \ "missing <!DOCTYPE> declaration",
                \ "inserting implicit <body>",
                \ "inserting missing 'title' element",
                \ "attribute \"[+",
                \ "unescaped & or unknown entity",
                \ "<input> attribute \"type\" has invalid value \"search\""
                \ ]

function! s:IgnoreError(text)
    for i in s:ignore_html_errors + g:syntastic_html_tidy_ignore_errors
        if stridx(a:text, i) != -1
            return 1
        endif
    endfor
    return 0
endfunction

function s:Args()
    let args = s:TidyEncOptByFenc() .
        \ ' --new-blocklevel-tags ' . shellescape('main, section, article, aside, hgroup, header, footer, nav, figure, figcaption') .
        \ ' --new-inline-tags ' . shellescape('video, audio, source, embed, mark, progress, meter, time, ruby, rt, rp, canvas, command, details, datalist') .
        \ ' --new-empty-tags ' . shellescape('wbr, keygen') .
        \ ' -e'
    return args
endfunction

function! SyntaxCheckers_html_tidy_GetLocList()
    let makeprg = syntastic#makeprg#build({
        \ 'exe': 'tidy',
        \ 'args': s:Args(),
        \ 'tail': '2>&1',
        \ 'filetype': 'html',
        \ 'subchecker': 'tidy' })

    let errorformat =
        \ '%Wline %l column %v - Warning: %m,' .
        \ '%Eline %l column %v - Error: %m,' .
        \ '%-G%.%#'

    let loclist = SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'defaults': {'bufnr': bufnr("")} })

    " filter out valid HTML5 from the errors
    for n in range(len(loclist))
        if loclist[n]['valid'] && s:IgnoreError(loclist[n]['text']) == 1
            let loclist[n]['valid'] = 0
        endif
    endfor

    return loclist
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'html',
    \ 'name': 'tidy'})

