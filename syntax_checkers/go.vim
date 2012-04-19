"============================================================================
"File:        go.vim
"Description: Loads a go syntax checker from the go directory
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
" Use g:syntastic_go_checker option to specify which go executable
" should be used (see below for a list of supported checkers).
" If g:syntastic_go_checker is not set, just use the first syntax
" checker that we find installed.
"============================================================================
if exists("loaded_go_syntax_checker")
    finish
endif
let loaded_go_syntax_checker = 1

let s:supported_checkers = ["go", "6g", "gofmt"]
call SyntasticLoadChecker(s:supported_checkers, 'go')
