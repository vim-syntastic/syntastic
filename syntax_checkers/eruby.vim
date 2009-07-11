if exists("loaded_eruby_syntax_checker")
    finish
endif
let loaded_eruby_syntax_checker = 1

"bail if the user doesnt have ruby or cat installed
if !executable("ruby") || !executable("cat")
    finish
endif

function! SyntaxCheckers_eruby_GetQFList()
    let &makeprg='cat '. expand("%") . ' \| ruby -e "require \"erb\"; puts ERB.new(ARGF.read, nil, \"-\").src" \| ruby -c'
    set errorformat=%-GSyntax\ OK,%E-:%l:\ syntax\ error\\,\ %m,%Z%p^,%W-:%l:\ warning:\ %m,%Z%p^,%-C%.%#
    silent make!

    "the file name isnt in the output so stick in the buf num manually
    let qflist = getqflist()
    for i in qflist
        let i['bufnr'] = bufnr("")
    endfor

    return qflist
endfunction
