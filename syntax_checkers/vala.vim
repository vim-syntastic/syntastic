"============================================================================
"File:        vala.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Konstantin Stepanov (me@kstep.me)
"Notes:       Add special comment line into your vala file starting with
"             "// modules: " and containing space delimited list of vala
"             modules, used by the file, so this script can build correct
"             --pkg arguments.
"             Valac compiler is not the fastest thing in the world, so you
"             may want to disable this plugin with
"             let g:syntastic_vala_check_disabled = 1 command in your .vimrc or
"             command line. Unlet this variable to set it to 0 to reenable
"             this checker.
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists('loaded_vala_syntax_checker')
    finish
endif
let loaded_vala_syntax_checker = 1

if !executable('valac')
    finish
endif

if exists('g:syntastic_vala_check_disabled') && g:syntastic_vala_check_disabled
    finish
endif

function! SyntaxCheckers_vala_Term(pos)
    let strlength = strlen(matchstr(a:pos['text'], '\^\+$'))
    return '\%>'.(a:pos.col-1).'c.*\%<'.(a:pos.col+strlength+1).'c'
endfunction

function! s:GetValaModules()
    let modules_line = search('^// modules: ', 'n')
    let modules_str = getline(modules_line)
    let modules = split(strpart(modules_str, 12), '\s\+')
    return modules
endfunction

function! SyntaxCheckers_vala_GetLocList()
    let vala_pkg_args = join(map(s:GetValaModules(), '"--pkg ".v:val'), ' ')
    let makeprg = 'valac -C ' . vala_pkg_args . ' ' .shellescape(expand('%'))
    let errorformat = '%A%f:%l.%c-%\d%\+.%\d%\+: %t%[a-z]%\+: %m,%C%m,%Z%m'

    let loclist = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
    call SyntasticHighlightErrors(loclist, function("SyntaxCheckers_vala_Term"), 1)
    return loclist
endfunction

