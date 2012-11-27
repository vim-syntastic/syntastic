"============================================================================
"File:        xml.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Sebastian Kusnier <sebastian at kusnier dot net>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

" You can use a local installation of DTDs to significantly speed up validation
" and allow you to validate XML data without network access, see xmlcatalog(1)
" and http://www.xmlsoft.org/catalog.html for more information.

"bail if the user doesnt have tidy or grep installed
if !executable("xmllint")
    finish
endif

function! SyntaxCheckers_xml_GetLocList()

    let makeprg="xmllint --xinclude --noout --postvalid " . shellescape(expand("%:p"))
    let errorformat='%E%f:%l:\ error\ :\ %m,
        \%-G%f:%l:\ validity\ error\ :\ Validation\ failed:\ no\ DTD\ found\ %m,
        \%W%f:%l:\ warning\ :\ %m,
        \%W%f:%l:\ validity\ warning\ :\ %m,
        \%E%f:%l:\ validity\ error\ :\ %m,
        \%E%f:%l:\ parser\ error\ :\ %m,
        \%E%f:%l:\ %m,
        \%-Z%p^,
        \%-G%.%#'
    let loclist = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

    return loclist
endfunction
