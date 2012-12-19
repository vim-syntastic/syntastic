if exists("g:loaded_syntastic_util_autoload")
    finish
endif
let g:loaded_syntastic_util_autoload = 1

let s:save_cpo = &cpo
set cpo&vim

function! syntastic#util#DevNull()
    if has('win32')
        return 'NUL'
    endif
    return '/dev/null'
endfunction

"search the first 5 lines of the file for a magic number and return a map
"containing the args and the executable
"
"e.g.
"
"#!/usr/bin/perl -f -bar
"
"returns
"
"{'exe': '/usr/bin/perl', 'args': ['-f', '-bar']}
function! syntastic#util#ParseShebang()
    for lnum in range(1,5)
        let line = getline(lnum)

        if line =~ '^#!'
            let exe = matchstr(line, '^#!\s*\zs[^ \t]*')
            let args = split(matchstr(line, '^#!\s*[^ \t]*\zs.*'))
            return {'exe': exe, 'args': args}
        endif
    endfor

    return {'exe': '', 'args': []}
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set et sts=4 sw=4:
