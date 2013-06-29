"============================================================================
"File:        gentoo-metadata.vim
"Description: Syntax checking plugin for Gentoo's metadata.xml files
"Maintainer:  James Rowe <jnrowe at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

" The DTDs required to validate metadata.xml files are available in
" $PORTDIR/metadata/dtd, and these local files can be used to significantly
" speed up validation.  You can create a catalog file with:
"
"   xmlcatalog --create --add rewriteURI http://www.gentoo.org/dtd/ \
"       ${PORTDIR:-/usr/portage}/metadata/dtd/ /etc/xml/gentoo
"
" See xmlcatalog(1) and http://www.xmlsoft.org/catalog.html for more
" information.

if exists("g:loaded_syntastic_gentoo_metadata_xmllint_checker")
    finish
endif
let g:loaded_syntastic_gentoo_metadata_xmllint_checker=1

function! SyntaxCheckers_gentoo_metadata_xmllint_IsAvailable()
    return SyntaxCheckers_xml_xmllint_IsAvailable()
endfunction

function! SyntaxCheckers_gentoo_metadata_xmllint_GetLocList()
    return SyntaxCheckers_xml_xmllint_GetLocList()
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'gentoo_metadata',
    \ 'name': 'xmllint'})

runtime! syntax_checkers/xml/*.vim
