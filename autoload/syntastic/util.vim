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

" Verify that the 'installed' version is at the 'required' version, if not
" better.
"
" 'installed' and 'required' must be arrays.  Only the
" first three elements (major, minor, patch) are looked at.
"
" Either array may be less than three elements. The "missing" elements
" will be assumed to be '0' for the purposes of checking.
"
" See http://semver.org for info about version numbers.
function syntastic#util#versionIsAtLeast(installed, required)
    for index in [0,1,2]
        if len(a:installed) <= index
            let installed_element = 0
        else
            let installed_element = a:installed[index]
        endif
        if len(a:required) <= index
            let required_element = 0
        else
            let required_element = a:required[index]
        endif
        if installed_element != required_element
            return installed_element > required_element
        endif
    endfor
    " Everything matched, so it is at least the required version.
    return 1
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set et sts=4 sw=4:
