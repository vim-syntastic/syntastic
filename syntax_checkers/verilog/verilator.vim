if exists("g:loaded_syntastic_verilog_verilator_checker")
    finish
endif
let g:loaded_syntastic_verilog_verilator_checker = 1

function! SyntaxCheckers_verilog_verilator_IsAvailable()
    return executable("verilator")
endfunction

function! SyntaxCheckers_verilog_verilator_GetLocList()
    let makeprg = syntastic#makeprg#build({
        \ 'exe': 'verilator',
        \ 'args': '--lint-only -Wall',
        \ 'filetype': 'verilog',
        \ 'subchecker': 'verilator' })

    let errorformat = '%%%trror: %f:%l: %m'
                      \ . ',%%%tarning-%s: %f:%l: %m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'verilog',
    \ 'name': 'verilator'})
