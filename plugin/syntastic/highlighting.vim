if exists("g:loaded_syntastic_notifier_highlighting")
    finish
endif
let g:loaded_syntastic_notifier_highlighting = 1

if !exists("g:syntastic_enable_highlighting")
    let g:syntastic_enable_highlighting = 1
endif

" Highlighting requires getmatches introduced in 7.1.040
if v:version < 701 || (v:version == 701 && !has('patch040'))
    let g:syntastic_enable_highlighting = 0
endif

let g:SyntasticHighlightingNotifier = {}

" Public methods {{{1

function! g:SyntasticHighlightingNotifier.New()
    let newObj = copy(self)
    return newObj
endfunction

function! g:SyntasticHighlightingNotifier.enabled()
    return exists('b:syntastic_enable_highlighting') ? b:syntastic_enable_highlighting : g:syntastic_enable_highlighting
endfunction

" The function `Syntastic_{filetype}_{checker}_GetHighlightRegex` is used
" to override default highlighting.  This function must take one arg (an
" error item) and return a regex to match that item in the buffer.
function! g:SyntasticHighlightingNotifier.refresh(loclist)
    let fts = substitute(&ft, '-', '_', 'g')
    for ft in split(fts, '\.')

        for item in a:loclist.filteredRaw()
            let group = item['type'] == 'E' ? 'SyntasticError' : 'SyntasticWarning'

            if has_key(item, 'hl')
                call matchadd(group, '\%' . item['lnum'] . 'l' . item['hl'])
            elseif get(item, 'col')
                let lastcol = col([item['lnum'], '$'])
                let lcol = min([lastcol, item['col']])

                " a bug in vim can sometimes cause there to be no 'vcol' key,
                " so check for its existence
                let coltype = has_key(item, 'vcol') && item['vcol'] ? 'v' : 'c'

                call matchadd(group, '\%' . item['lnum'] . 'l\%' . lcol . coltype)
            endif
        endfor
    endfor
endfunction

" Remove all error highlights from the window
function! g:SyntasticHighlightingNotifier.reset(loclist)
    for match in getmatches()
        if stridx(match['group'], 'Syntastic') == 0
            call matchdelete(match['id'])
        endif
    endfor
endfunction

" vim: set sw=4 sts=4 et fdm=marker:
