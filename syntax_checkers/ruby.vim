"============================================================================
"File:        ruby.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Martin Grenfell <martin.grenfell at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"Supports MRI, JRuby and MacRuby but loads the MRI syntax checker by default.
"Use the g:syntastic_ruby_exec option to specify the executable to call
"Use the g:syntastic_ruby_checker option to specify which checker to load -
"it will default to 'macruby' or 'jruby' if that is the value of
"g:syntastic_ruby_exec
"If you have rvm installed the correct exec and checker will be set based on
"your currently selected ruby
"
"Examples:
"set _exec | set _checker | rvm | output_exec  | output_checker
"no        | no           | no  | ruby         | mri
"no        | no           | yes | from rvm     | from rvm
"ruby      | no           |     | ruby         | mri
"ruby18    | no           |     | ruby18       | mri
"no        | jruby        |     | jruby        | jruby
"jruby     | no           |     | jruby        | jruby
"jruby     | jruby        |     | jruby        | jruby
"ruby18    | jruby        |     | ruby18       | jruby
"============================================================================
if exists("loaded_ruby_syntax_checker")
    finish
endif
let loaded_ruby_syntax_checker = 1

function! s:is_jruby_or_macvim(str)
    return "jruby" == a:str || "macvim" == a:str
endfunction

if !exists("g:syntastic_ruby_exec")
    let g:syntastic_ruby_exec = "ruby"
    let s:i_set_ruby_exec = 1
    if !exists(g:syntastic_ruby_checker) && executable("rvm")
        let ident = system("rvm tools identifier")
        let ident = substitute(ident, '-.*', '', '')
        if s:is_jruby_or_macvim(ident)
            let g:syntastic_ruby_checker = ident
            let s:i_set_ruby_checker = 1
        endif
    endif
endif

if !exists("g:syntastic_ruby_checker")
    if s:is_jruby_or_macvim(g:syntastic_ruby_exec)
        let g:syntastic_ruby_checker = g:syntastic_ruby_exec
    else
        let g:syntastic_ruby_checker = "mri"
    endif
elseif !exists("s:i_set_ruby_checker") && exists("s:i_set_ruby_exec")
    if s:is_jruby_or_macvim(g:syntastic_ruby_checker)
        let g:syntastic_ruby_exec = g:syntastic_ruby_checker
    endif
endif

"bail if the user doesnt have ruby installed where they said it is
if !executable(g:syntastic_ruby_exec)
    finish
endif
exec "runtime! syntax_checkers/ruby/" . g:syntastic_ruby_checker . ".vim"

