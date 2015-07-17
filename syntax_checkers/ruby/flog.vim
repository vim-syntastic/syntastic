"============================================================================
"File:        flog.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Tim Carry <tim at pixelastic dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists('g:loaded_syntastic_ruby_flog_checker')
    finish
endif
let g:loaded_syntastic_ruby_flog_checker = 1

if !exists('g:syntastic_ruby_flog_threshold_warning')
    let g:syntastic_ruby_flog_threshold_warning = 45
endif

if !exists('g:syntastic_ruby_flog_threshold_error')
    let g:syntastic_ruby_flog_threshold_error = 90
endif

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_ruby_flog_GetLocList() dict
    let makeprg = self.makeprgBuild({})

    " Example output:
    "   93.25: MyClass::my_method my_file:42
    "
    " %p for the leading spaces
    " %m for the message (score)
    " :\ %.%#: for anything in between the :
    " %l for the line number
    let errorformat = '%p%m:\ %.%#:%l'

    let loclist = SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'defaults': {'bufnr': bufnr('')},
        \ 'errorformat': errorformat})

    " Split output into error and warning
    let min = g:syntastic_ruby_flog_threshold_warning
    let max = g:syntastic_ruby_flog_threshold_error
    for e in loclist
      if e['valid'] ==# '0'
        continue
      endif

      let score = str2nr(e['text'])
      " Discard scores too low
      if score < min
        let e['valid'] = '0'
        continue
      endif

      " Set as warning or error based on the thresholds
      let e['text'] = 'Complexity is too high (' . score . '/'
      if score > max
        let e['type'] = 'E'
        let e['text'] .= max . ')'
      else
        let e['type'] = 'W'
        let e['text'] .= min . ')'
      endif
    endfor

    return loclist
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'ruby',
    \ 'name': 'flog'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
