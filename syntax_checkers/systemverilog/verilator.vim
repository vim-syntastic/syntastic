if exists("g:loaded_syntastic_systemverilog_verilator_checker")
    finish
endif
let g:loaded_syntastic_systemverilog_verilator_checker = 1

function! SyntaxCheckers_systemverilog_verilator_IsAvailable()
    return executable("verilator")
endfunction

function! SyntaxCheckers_systemverilog_verilator_GetLocList()
    let makeprg = syntastic#makeprg#build({
        \ 'exe': 'verilator',
        \ 'args': '-sv --lint-only -Wall',
        \ 'filetype': 'systemverilog',
        \ 'subchecker': 'verilator' })

    let errorformat = '%%%trror: %f:%l: %m'
                      \ . ',%%%tarning-%*: %f:%l: %m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'systemverilog',
    \ 'name': 'verilator'})
