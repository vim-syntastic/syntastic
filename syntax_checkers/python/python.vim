"============================================================================
"File:        python.vim
"Description: Syntax checking plugin for syntastic.vim
"Author:      Artem Nezvigin <artem at artnez dot com>
"
" `errorformat` derived from:
" http://www.vim.org/scripts/download_script.php?src_id=1392
"
"============================================================================
if exists("g:loaded_syntastic_python_python_checker")
    finish
endif
let g:loaded_syntastic_python_python_checker=1

function! SyntaxCheckers_python_python_GetLocList() dict
    let fname = "'" . escape(expand('%'), "\\'") . "'"

    let makeprg = self.makeprgBuild({
        \ 'args': '-c',
        \ 'fname': syntastic#util#shescape("compile(open(" . fname . ").read(), " . fname . ", 'exec')") })

    let errorformat =
        \ '%E  File "%f"\, line %l,' .
        \ '%C    %p^,' .
        \ '%C    %.%#,' .
        \ '%Z%m,' .
        \ '%-G%.%#'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'python',
    \ 'name': 'python'})
