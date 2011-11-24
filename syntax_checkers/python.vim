"============================================================================
"File:        python.vim
"Description: Syntax checking plugin for syntastic.vim
"
"Authors:     Martin Grenfell <martin.grenfell@gmail.com>
"             kstep <me@kstep.me>
"
"============================================================================

" in order to force the use of pyflakes if both flake8 and pyflakes are
" available, add this to your .vimrc:
"
"   let g:syntastic_python_checker = 'pyflakes'

if exists("loaded_python_syntax_checker")
    finish
endif
let loaded_python_syntax_checker = 1

"bail if the user doesnt have his favorite checker or flake8 or pyflakes installed
if !exists('g:syntastic_python_checker') || !executable('g:syntastic_python_checker')
   if executable("flake8")
      let g:syntastic_python_checker = 'flake8'
   elseif executable("pyflakes")
      let g:syntastic_python_checker = 'pyflakes'
   else
      finish
   endif
endif

function! SyntaxCheckers_python_Term(i)
    if a:i['type'] ==# 'E'
        let a:i['text'] = "Syntax error"
    endif
    if match(a:i['text'], 'is assigned to but never used') > -1
                \ || match(a:i['text'], 'imported but unused') > -1
                \ || match(a:i['text'], 'undefined name') > -1
                \ || match(a:i['text'], 'redefinition of') > -1
                \ || match(a:i['text'], 'referenced before assignment') > -1
                \ || match(a:i['text'], 'duplicate argument') > -1
                \ || match(a:i['text'], 'after other statements') > -1
                \ || match(a:i['text'], 'shadowed by loop variable') > -1

        let term = split(a:i['text'], "'", 1)[1]
        return '\V\<'.term.'\>'
    endif
    return ''
endfunction

function! SyntaxCheckers_python_GetLocList()
    let makeprg = g:syntastic_python_checker.' '.shellescape(expand('%'))
    let errorformat =
        \ '%E%f:%l: could not compile,%-Z%p^,%W%f:%l:%c: %m,%W%f:%l: %m,%-G%.%#'

    let errors = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

    call syntastic#HighlightErrors(errors, function('SyntaxCheckers_python_Term'))

    return errors
endfunction
