"============================================================================
"File:        sh.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Gregor Uhlenheuer <kongo2002 at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
if exists('loaded_sh_syntax_checker')
    finish
endif
let loaded_sh_syntax_checker = 1

function! GetShell()
    let shebang = getbufline(bufnr('%'), 1)[0]
    if len(shebang) > 0
        if match(shebang, 'bash') >= 0
            return 'bash'
        elseif match(shebang, 'zsh') >= 0
            return 'zsh'
        elseif match(shebang, 'sh') >= 0
            return 'sh'
        endif
    endif
    return ''
endfunction

function! SyntaxCheckers_sh_GetLocList()
    if !exists('b:shell')
        let b:shell = GetShell()
    endif
    if len(b:shell) == 0 || !executable(b:shell)
        return []
    endif
    let output = split(system(b:shell.' -n '.shellescape(expand('%'))), '\n')
    if v:shell_error != 0
        let result = []
        for err_line in output
            let line = substitute(err_line, '^[^:]*:\D\{-}\(\d\+\):.*', '\1', '')
            let msg = substitute(err_line, '^[^:]*:\D\{-}\d\+: \(.*\)', '\1', '')
            call add(result, {'lnum' : line,
                            \ 'text' : msg,
                            \ 'bufnr': bufnr(''),
                            \ 'type': 'E' })
        endfor
        return result
    endif
    return []
endfunction
