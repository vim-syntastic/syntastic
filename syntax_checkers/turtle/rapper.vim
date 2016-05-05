"============================================================================
"File:        rapper.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Sebastian Tramp <mail@sebastian.tramp.name>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"============================================================================
"
" file is build based on the given guide as well as existing checker plugins
" https://github.com/scrooloose/syntastic/wiki/Syntax-Checker-Guide

if exists('g:loaded_syntastic_turtle_rapper_checker') " {{{1
    finish
else
    let g:loaded_syntastic_turtle_rapper_checker = 1
endif " }}}1"

" reset options to the Vim defaults {{{1
" http://vi.stackexchange.com/questions/2116
let s:save_cpo = &cpo
set cpo&vim
" }}}1

" verify that the checker is installed and any other environment deps are met
function! SyntaxCheckers_turtle_rapper_IsAvailable() dict " {{{1
    return executable(self.getExec())
endfunction " }}}1

" perform the syntax check and return the results in the form of a quickfix list
function! SyntaxCheckers_turtle_rapper_GetLocList() dict " {{{1

    " Create the program call via makeprg
    "   example call: rapper -i guess -q --count file.ttl
    "   this uses "-i guess" in order to allow to redirect other rdf formats
    let makeprg = self.makeprgBuild({
                \ 'args': '-i guess -q --count ',
                \ 'args_after': '' })

    " Create error format matching lines
    "   Example output:
    "     rapper: Error - URI file:///.../file.ttl:39 - syntax error, unexpected a
    let errorformat = 'rapper: Error - URI file://%f:%l - %m'

    " sets up the environment according to the options given, runs the checker,
    " resets the environment, and returns the location list
    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat})
endfunction " }}}1

" return a regular expression pattern matching the current error in order to
" highlight parts of the line
function! SyntaxCheckers_turtle_rapper_GetHighlightRegex(item) " {{{1
    let term = matchstr(a:item['text'], '\mFailed to convert qname \zs\S\+\ze to URI')
    if term !=# ''
        let term = '\V' . escape(term, '\')
    endif
    return term
endfunction " }}}1

" tell syntastic that this plugin exists {{{1
call g:SyntasticRegistry.CreateAndRegisterChecker({
            \ 'filetype': 'turtle',
            \ 'name': 'rapper',
            \ 'exec': 'rapper' })
" }}}1

" reload saved options {{{1
" http://vi.stackexchange.com/questions/2116
let &cpo = s:save_cpo
unlet s:save_cpo
" }}}1

" vim: set sw=4 sts=4 et fdm=marker:
