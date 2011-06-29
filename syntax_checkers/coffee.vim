"============================================================================
"File:        coffee.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Lincoln Stoll <l@lds.li>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists("loaded_coffee_syntax_checker")
    finish
endif
let loaded_coffee_syntax_checker = 1

"bail if the user doesnt have coffee installed
if !executable("coffee")
    finish
endif

function! SyntaxCheckers_coffee_GetLocList()
    let makeprg = 'coffee -c -l -o /tmp %'
    let errorformat =  '%EError: In %f\, Parse error on line %l: %m,%EError: In %f\, %m on line %l,%W%f(%l): lint warning: %m,%-Z%p^,%W%f(%l): warning: %m,%-Z%p^,%E%f(%l): SyntaxError: %m,%-Z%p^,%-G'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction
