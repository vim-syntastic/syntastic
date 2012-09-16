"============================================================================
"File:        elixir.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Richard Ramsden <rramsden at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists("loaded_elixir_syntax_checker")
    finish
endif
let loaded_elixir_syntax_checker = 1

if !executable('elixir')
  finish
endif

function! SyntaxCheckers_elixir_GetLocList()
  let makeprg = 'elixir ' . shellescape(expand('%'))
  let errorformat = '** %*[^\ ] %f:%l: %m'

  let elixir_results = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

  if !empty(elixir_results)
    return elixir_results
  endif
endfunction
