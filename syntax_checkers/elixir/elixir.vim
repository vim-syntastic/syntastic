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

if exists("g:loaded_syntastic_elixir_elixir_checker")
    finish
endif
let g:loaded_syntastic_elixir_elixir_checker = 1

let s:save_cpo = &cpo
set cpo&vim

" TODO: we should probably split this into separate checkers
function! SyntaxCheckers_elixir_elixir_IsAvailable() dict
    call self.log(
        \ 'executable("elixirc") = ' . executable('elixirc') . ', ' .
        \ 'executable("mix") = ' . executable('mix'))
    return executable('elixirc') && executable('mix')
endfunction

function! SyntaxCheckers_elixir_elixir_GetLocList() dict
    if !exists('g:syntastic_enable_elixir_checker') || !g:syntastic_enable_elixir_checker
        call syntastic#log#error('checker elixir/elixir: checks disabled for security reasons; ' .
            \ 'set g:syntastic_enable_elixir_checker to 1 to override')
        return []
    endif

    let make_options = {}
    let compile_command = 'elixirc --ignore-module-conflict -o /tmp'
    let mix_file = syntastic#util#findInParent('mix.exs', expand('%:p:h', 1))

    if filereadable(mix_file)
        let compile_command = 'mix compile'
        let make_options['cwd'] = fnamemodify(mix_file, ':p:h')
    endif

    let make_options['makeprg'] = self.makeprgBuild({ 'exe': compile_command })

    " ----- errorformat  -----

    " error sample:
    " ** (CompileError) elixir-lazy.exs:13: undefined function asdfasd/0
    "     (stdlib) lists.erl:1352: :lists.mapfoldl/3
    "     (stdlib) lists.erl:1353: :lists.mapfoldl/3
    let efm = '** (%*[^\ ]%trror) %f:%l: %m'

    " warning sample:
    " elixir-lazy.exs:8: warning: variable n is unused
    let efm .= ',%f:%l: %tarning: %m'

    " error sample:
    " ** (UndefinedFunctionError) undefined function: Problem2.multiples_of_3_5__range/1
    "     Problem2.multiples_of_3_5__range(1000)
    "     elixir-lazy.exs:13: (file)
    "     (elixir) lib/code.ex:316: Code.require_file/2
    let efm .= ',%A** (%*[^\ ]%trror) %m,%Z    %f:%l: (file),%-C    (elixir) %.%#,%+C    %m'

    let make_options['errorformat'] = efm

    return SyntasticMake(make_options)
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'elixir',
    \ 'name': 'elixir'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
