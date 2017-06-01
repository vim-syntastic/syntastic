" vim: set sw=4 sts=4 et fdm=marker:
scriptencoding utf-8
if exists('g:loaded_syntastic_elixir_credo_checker')
    finish
endif
let g:loaded_syntastic_elixir_credo_checker = 1

if !exists('g:syntastic_elixir_credo_all')
  let g:syntastic_elixir_credo_all = 1
endif

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_elixir_credo_IsAvailable() dict
    call self.log('executable("elixir") = ' . executable('elixir'))
    if !executable('elixir')
        return 0
    endif

    call self.log('executable("mix") = ' . executable('mix'))
    if !executable('mix')
        return 0
    endif

    call self.log('syntastic#util#system("mix credo help") = ' . syntastic#util#system('mix credo help'))
    if match(syntastic#util#system('mix credo help'), 'The task "credo" could not be found') == -1
        return 1
    endif

    return 0
endfunction

function! SyntaxCheckers_elixir_credo_GetLocList() dict
    let make_options = {}

    " let mix_file = syntastic#util#findFileInParent('mix.exs', expand('%:p:h', 1))
    " if filereadable(mix_file)
    "     let make_options['cwd'] = fnamemodify(mix_file, ':p:h')
    " endif

    let compile_command = 'mix credo --format oneline'
    if g:syntastic_elixir_credo_all
        let compile_command .= ' --all'
    endif

    let make_options['makeprg'] = self.makeprgBuild({ 'exe': compile_command })

    let make_options['errorformat'] =
        \ '%E[%.] ↑ %f:%l:%c %m,' .
        \ '%E[%.] ↗ %f:%l:%c %m,' .
        \ '%W[%.] → %f:%l:%c %m,' .
        \ '%W[%.] ↘ %f:%l:%c %m,' .
        \ '%I[%.] ↓ %f:%l:%c %m,' .
        \ '%I[%.] ? %f:%l:%c %m'

    return SyntasticMake(make_options)
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'elixir',
    \ 'name': 'credo'})

let &cpo = s:save_cpo
unlet s:save_cpo
