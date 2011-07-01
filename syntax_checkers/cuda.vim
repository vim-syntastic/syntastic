"============================================================================
"File:        cuda.vim
"Description: Syntax checking plugin for syntastic.vim
"
"Author:      Hannes Schulz <schulz at ais dot uni-bonn dot de>
"
"============================================================================

" in order to also check header files add this to your .vimrc:
" (this creates an empty .syntastic_dummy.cu file in your source directory)
"
"   let g:syntastic_cuda_check_header = 1

if exists('loaded_cuda_syntax_checker')
    finish
endif
let loaded_cuda_syntax_checker = 1

if !exists('g:syntastic_nvcc_binary')
	let g:syntastic_nvcc_binary = '/usr/local/cuda/bin/nvcc'
endif
if !executable('/usr/local/cuda/bin/nvcc')
    finish
endif

function! SyntaxCheckers_cuda_GetLocList()
    let makeprg = g:syntastic_nvcc_binary.' --cuda -O0 -I . -Xcompiler -fsyntax-only '.shellescape(expand('%')).' -o /dev/null'
    "let errorformat =  '%-G%f:%s:,%f:%l:%c: %m,%f:%l: %m'
    let errorformat =  '%*[^"]"%f"%*\D%l: %m,"%f"%*\D%l: %m,%-G%f:%l: (Each undeclared identifier is reported only once,%-G%f:%l: for each function it appears in.),%f:%l:%c:%m,%f(%l):%m,%f:%l:%m,"%f"\, line %l%*\D%c%*[^ ] %m,%D%*\a[%*\d]: Entering directory `%f'',%X%*\a[%*\d]: Leaving directory `%f'',%D%*\a: Entering directory `%f'',%X%*\a: Leaving directory `%f'',%DMaking %*\a in %f,%f|%l| %m'

    if expand('%') =~? '\%(.h\|.hpp\|.cuh\)$'
        if exists('g:syntastic_cuda_check_header')
            let makeprg = 'echo > .syntastic_dummy.cu ; '.g:syntastic_nvcc_binary.' --cuda -O0 -I . .syntastic_dummy.cu -Xcompiler -fsyntax-only -include '.shellescape(expand('%')).' -o /dev/null'
        else
            return []
        endif
    endif

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction
