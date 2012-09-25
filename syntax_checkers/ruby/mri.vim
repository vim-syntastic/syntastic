"============================================================================
"File:        mri.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
function! SyntaxCheckers_ruby_GetLocList()
    let makeprg = expand(g:syntastic_ruby_exec).' -w -T1 -c '.shellescape(expand('%'))
    if !has('win32')
        let makeprg = 'RUBYOPT= ' . makeprg
    endif

    "this is a hack to filter out a repeated useless warning in rspec files
    "containing lines like
    "
    "  foo.should == 'bar'
    "
    "Which always generate the warning below. Note that ruby >= 1.9.3 includes
    "the word "possibly" in the warning
    let errorformat = '%-G%.%#warning: %\(possibly %\)%\?useless use of == in void context'

    " filter out lines starting with ...
    " long lines are truncated and wrapped in ... %p then returns the wrong
    " column offset
    let errorformat .= ',%-G%\%.%\%.%\%.%.%#'

    let errorformat .= ',%-GSyntax OK,%E%f:%l: syntax error\, %m'
    let errorformat .= ',%Z%p^,%W%f:%l: warning: %m,%Z%p^,%W%f:%l: %m,%-C%.%#'
    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction
