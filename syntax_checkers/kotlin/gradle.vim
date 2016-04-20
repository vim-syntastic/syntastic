if exists('g:loaded_syntastic_kotlin_gradle_checker')
    finish
endif
let g:loaded_syntastic_kotlin_gradle_checker = 1

if !exists('g:syntastic_kotlin_gradle_sort')
    let g:syntastic_kotlin_gradle_sort = 1
endif

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_kotlin_gradle_IsAvailable() dict
    return executable(self.getExec())
endfunction

function! SyntaxCheckers_kotlin_gradle_GetLocList() dict
    let errorformat = '%t:\ %f:\ (%l\,\ %c): %m,'

    return SyntasticMake({ 'makeprg': 'gradle --daemon check 2>&1 >/dev/null', 'errorformat': errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
            \ 'filetype': 'kotlin',
            \ 'name': 'gradle',
            \ 'exec': 'gradle' })

let &cpo = s:save_cpo
unlet s:save_cpo
