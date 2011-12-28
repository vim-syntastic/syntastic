"============================================================================
"File:        haxe.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Lincoln Stoll <l@lds.li>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists("loaded_haxe_syntax_checker")
    finish
endif
let loaded_haxe_syntax_checker = 1

"bail if the user doesn't have haxe installed
if !executable("haxe")
  echo "haxe not found"
  finish
endif

" Find_in_parent
" find the file argument and returns the path to it.
" Starting with the current working dir, it walks up the parent folders
" until it finds the file, or it hits the stop dir.
" If it doesn't find it, it returns "Nothing"
function! Find_in_parent(fln,flsrt,flstp)
  let here = a:flsrt
  while ( strlen( here) > 0 )
    let p = split(globpath(here, a:fln), '\n')
    if len(p) > 0
      return ['ok', here, fnamemodify(p[0], ':p:t')]
    endif
    let fr = match(here, '/[^/]*$')
    if fr == -1
      break
    endif
    let here = strpart(here, 0, fr)
    if here == a:flstp
      break
    endif
  endwhile
  return ['fail', '', '']
endfunction

function! SyntaxCheckers_haxe_GetLocList()
    let [success, hxmldir, hxmlname] = Find_in_parent('*.hxml', expand('%:p:h'), '/')
    if success == 'ok'
      let makeprg = 'cd ' . hxmldir . '; haxe ' . hxmlname
      let errorformat = '%E%f:%l: characters %c-%*[0-9] : %m'
      return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
    else
      return SyntasticMake({})
    endif
endfunction
