if exists("g:loaded_syntastic_gcc_autoload")
    finish
endif
let g:loaded_syntastic_gcc_autoload = 1

let s:save_cpo = &cpo
set cpo&vim


function! syntastic#gcc#GetLocList(filetype, options)
    let ft = a:filetype
    let errorformat = exists('g:syntastic_' . ft . '_errorformat') ?
        \ g:syntastic_{ft}_errorformat : a:options['errorformat']

    " determine whether to parse header files as well
    if expand('%') =~? a:options['headers_pattern']
        if exists('g:syntastic_' . ft . '_check_header') && g:syntastic_{ft}_check_header
            let makeprg =
                \ g:syntastic_{ft}_compiler .
                \ ' ' . get(a:options, 'makeprg_headers', '') .
                \ ' ' . g:syntastic_{ft}_compiler_options .
                \ ' ' . syntastic#c#GetIncludeDirs(ft) .
                \ ' ' . syntastic#c#NullOutput(ft) .
                \ ' -c ' . shellescape(expand('%'))
        else
            return []
        endif
    else
        let makeprg =
            \ g:syntastic_{ft}_compiler .
            \ ' ' . get(a:options, 'makeprg_main', '') .
            \ ' ' . g:syntastic_{ft}_compiler_options .
            \ ' ' . syntastic#c#GetIncludeDirs(ft) .
            \ ' ' . shellescape(expand('%'))
    endif

    " check if the user manually set some cflags
    if !exists('b:syntastic_' . ft . '_cflags')
        " check whether to search for include files at all
        if !exists('g:syntastic_' . ft . '_no_include_search') || !g:syntastic_{ft}_no_include_search
            if ft ==# 'c' || ft ==# 'cpp'
                " refresh the include file search if desired
                if exists('g:syntastic_' . ft . '_auto_refresh_includes') && g:syntastic_{ft}_auto_refresh_includes
                    let makeprg .= ' ' . syntastic#c#SearchHeaders()
                else
                    " search for header includes if not cached already
                    if !exists('b:syntastic_' . ft . '_includes')
                        let b:syntastic_{ft}_includes = syntastic#c#SearchHeaders()
                    endif
                    let makeprg .= ' ' . b:syntastic_{ft}_includes
                endif
            endif
        endif
    else
        " use the user-defined cflags
        let makeprg .= ' ' . b:syntastic_{ft}_cflags
    endif

    " add optional config file parameters
    let makeprg .= ' ' . syntastic#c#ReadConfig(g:syntastic_{ft}_config_file)

    " process makeprg
    let errors = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

    " filter the processed errors if desired
    if exists('g:syntastic_' . ft . '_remove_include_errors') && g:syntastic_{ft}_remove_include_errors
        call filter(errors, 'get(v:val, "bufnr") == ' . bufnr(''))
    endif

    return errors
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sts=4 sw=4 fdm=marker:
