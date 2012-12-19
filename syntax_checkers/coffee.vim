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

"bail if the user doesnt have coffee installed
if !executable("coffee")
    finish
endif

if !exists('g:syntastic_coffee_lint_options')
    let g:syntastic_coffee_lint_options = ""
endif


function! SyntaxCheckers_coffee_GetLocList()
    let makeprg = 'coffee -c -l -o /tmp '.shellescape(expand('%'))
    let errorformat =  'Syntax%trror: In %f\, %m on line %l,%EError: In %f\, Parse error on line %l: %m,%EError: In %f\, %m on line %l,%W%f(%l): lint warning: %m,%-Z%p^,%W%f(%l): warning: %m,%-Z%p^,%E%f(%l): SyntaxError: %m,%-Z%p^,%-G%.%#'

    let coffee_results = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

    if !empty(coffee_results)
        return coffee_results
    endif

    if executable("coffeelint")
        return s:GetCoffeeLintErrors()
    endif

    return []
endfunction

function s:GetCoffeeLintErrors()
    let coffeelint = 'coffeelint --csv '.g:syntastic_coffee_lint_options.' '.shellescape(expand('%'))
    let lint_results = SyntasticMake({ 'makeprg': coffeelint, 'errorformat': '%f\,%l\,%trror\,%m', 'subtype': 'Style' })

    return lint_results
endfunction
