"============================================================================
"File:        rust.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Chad Jablonski <chad.jablonski at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

"bail if the user doesnt have rustc installed
if !executable("rustc")
    finish
endif

function! SyntaxCheckers_rust_GetLocList()
    let makeprg = 'rustc --parse-only '.shellescape(expand('%'))

    let errorformat  = '%E%f:%l:%c: \\d%#:\\d%# %.%\{-}error:%.%\{-} %m,'   .
                     \ '%W%f:%l:%c: \\d%#:\\d%# %.%\{-}warning:%.%\{-} %m,' .
                     \ '%C%f:%l %m,' .
                     \ '%-Z%.%#'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction


