"============================================================================
"File:        z80.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Romain Giot <giot.romain at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists("loaded_z80_syntax_checker")
    finish
endif
let loaded_z80_syntax_checker = 1

"bail if the user doesnt have z80_syntax_checker.py installed
"To obtain this application there are two solutions:
" - Install this python package: https://github.com/rgiot/pycpcdemotools
" - Copy/paste this script in your search path: https://raw.github.com/rgiot/pycpcdemotools/master/cpcdemotools/source_checker/z80_syntax_checker.py
if !executable("z80_syntax_checker.py")
    finish
endif

function! SyntaxCheckers_z80_GetLocList()
    let makeprg = 'z80_syntax_checker.py '.shellescape(expand('%'))
    let errorformat =  '%f:%l %m' 
    let loclist = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
    return loclist
endfunction

