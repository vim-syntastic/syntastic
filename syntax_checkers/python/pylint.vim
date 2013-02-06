"============================================================================
"File:        pylint.vim
"Description: Syntax checking plugin for syntastic.vim
"Author:      Parantapa Bhattacharya <parantapa at gmail dot com>
"
"============================================================================
function! SyntaxCheckers_python_pylint_IsAvailable()
    return executable('pylint')
endfunction

function! SyntaxCheckers_python_pylint_GetLocList()
    let makeprg = syntastic#makeprg#build({
                \ 'exe': 'pylint',
                \ 'args': ' -f parseable -r n -i y',
                \ 'subchecker': 'pylint' })
    let errorformat = '%f:%l:%m,%Z,%-GNo config %m'

    let loclist=SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })

    let n = len(loclist) - 1
    while n >= 0
        let loclist[n]['type'] = match(['R', 'C', 'W'], loclist[n]['text'][2]) >= 0 ? 'W' : 'E'
        let n -= 1
    endwhile

    return sort(loclist, 's:CmpLoclist')
endfunction

function! s:CmpLoclist(a, b)
    return a:a['lnum'] - a:b['lnum']
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'python',
    \ 'name': 'pylint' })
