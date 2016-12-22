"============================================================================
"File:        vala.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Konstantin Stepanov (me@kstep.me)
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists('g:loaded_syntastic_vala_valac_checker')
    finish
endif
let g:loaded_syntastic_vala_valac_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_vala_valac_GetHighlightRegex(pos) " {{{1
    let length = strlen(matchstr(a:pos['text'], '\m\^\+$'))
    return '\%>' . (a:pos['col'] - 1) . 'c\%<' . (a:pos['col'] + length) . 'c'
endfunction " }}}1

function! SyntaxCheckers_vala_valac_GetLocList() dict " {{{1
    let vala_pkg_args = join(map(s:GetValaModules(), '"--pkg ".v:val'), ' ')
    let vala_vapi_args = join(map(s:GetValaVapiDirs(), '"--vapidir ".v:val'), ' ')
    let vala_src_args = join(map(s:GetValaSources(), 'v:val.".vala"'), ' ')
    let vala_flag_args = join(map(s:GetValaFlags(), '"--".v:val'), ' ')
    let makeprg = self.makeprgBuild({ 'args': '-C ' . vala_flag_args . ' ' . vala_src_args . ' ' . vala_pkg_args . ' ' . vala_vapi_args })

    let errorformat =
        \ '%A%f:%l.%c-%\d%\+.%\d%\+: %t%[a-z]%\+: %m,'.
        \ '%C%m,'.
        \ '%Z%m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat })
endfunction " }}}1

" Utilities {{{1

function! s:GetValaModules() " {{{2
    if exists('g:syntastic_vala_modules') || exists('b:syntastic_vala_modules')
        let modules = syntastic#util#var('vala_modules')
        if type(modules) == type('')
            return split(modules, '\m\s\+')
        elseif type(modules) == type([])
            return copy(modules)
        else
            echoerr 'syntastic_vala_modules must be either list or string: fallback to in file modules string'
        endif
    endif

    let modules_line = search('^// modules: ', 'n')
    let modules_str = getline(modules_line)
    return split(strpart(modules_str, 12), '\m\s\+')
endfunction " }}}2

function! s:GetValaVapiDirs() " {{{2
    if exists('g:syntastic_vala_vapi_dirs') || exists('b:syntastic_vala_vapi_dirs')
        let vapi_dirs = syntastic#util#var('vala_vapi_dirs')
        if type(vapi_dirs) == type('')
            return split(vapi_dirs, '\m\s\+')
        elseif type(vapi_dirs) == type([])
            return copy(vapi_dirs)
        else
            echoerr 'syntastic_vala_vapi_dirs must be either a list, or a string: fallback to in-file modules string'
        endif
    endif

    let vapi_line = search('^//\s*vapidirs:\s*','n')
    let vapi_str = getline(vapi_line)
    return split( substitute( vapi_str, '\m^//\s*vapidirs:\s*', '', 'g' ), '\m\s\+' )
endfunction " }}}2

function! s:GetValaSources() " {{{2
    if exists('g:syntastic_vala_sources') || exists('b:syntastic_vala_sources')
        let sources = syntastic#util#var('vala_sources')
        if type(sources) == type('')
            return split(sources, '\m\s\+')
        elseif type(sources) == type([])
            return copy(sources)
        else
            echoerr 'syntastic_vala_sources must be either a list, or a string: fallback to in-file modules string'
        endif
    endif

    let sources_line = search('^// sources: ', 'n')
    let sources_str = getline(sources_line)
    return split(strpart(sources_str, 12), '\m\s\+')
endfunction " }}}2

function! s:GetValaFlags() " {{{2
    if exists('g:syntastic_vala_flags') || exists('b:syntastic_vala_flags')
        let flags = syntastic#util#var('vala_flags')
        if type(flags) == type('')
            return split(flags, '\m\s\+')
        elseif type(flags) == type([])
            return copy(flags)
        else
            echoerr 'syntastic_vala_flags must be either a list, or a string: fallback to in-file modules string'
        endif
    endif

    let flags = search('^// flags: ', 'n')
    let flags = getline(flags)
    return split(strpart(flags, 10), '\m\s\+')
endfunction " }}}2

" }}}1

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'vala',
    \ 'name': 'valac'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
