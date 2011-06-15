"============================================================================
"File:        sass.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists("loaded_sass_syntax_checker")
    finish
endif
let loaded_sass_syntax_checker = 1

"bail if the user doesnt have the sass binary installed
if !executable("sass")
    finish
endif

let g:syntastic_sass_imports = 0

function! SyntaxCheckers_sass_GetLocList()
    "use compass imports if available
    if g:syntastic_sass_imports == 0 && executable("compass")
        let g:syntastic_sass_imports = system("compass imports")
    else
        let g:syntastic_sass_imports = ""
    endif

    let makeprg='sass '.g:syntastic_sass_imports.' --check '.shellescape(expand('%'))
    let errorformat = '%ESyntax %trror:%m,%C        on line %l of %f,%Z%m'
    let errorformat .= ',%Wwarning on line %l:,%Z%m,Syntax %trror on line %l: %m'
    let loclist = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

    let bn = bufnr("")
    for i in loclist
        let i['bufnr'] = bn
    endfor

    return loclist
endfunction
