"============================================================================
"File:        d.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Alfredo Di Napoli <alfredo dot dinapoli at gmail dot com>
"License:     Based on the original work of Gregor Uhlenheuer and his
"             cpp.vim checker so credits are dued.
"             THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
"             EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
"             OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
"             NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
"             HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
"             WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
"             FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
"             OTHER DEALINGS IN THE SOFTWARE.
"
"============================================================================

if exists('g:loaded_syntastic_d_dmd_checker')
    finish
endif
let g:loaded_syntastic_d_dmd_checker = 1

if !exists('g:syntastic_d_compiler_options')
    let g:syntastic_d_compiler_options = ''
endif

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_d_dmd_IsAvailable() dict
    if !exists('g:syntastic_d_compiler')
        let g:syntastic_d_compiler = self.getExec()
    endif
    call self.log('g:syntastic_d_compiler =', g:syntastic_d_compiler)
    return executable(expand(g:syntastic_d_compiler, 1))
endfunction

function! SyntaxCheckers_d_dmd_GetLocList() dict
    let dubPaths = []

    if executable('dub')
        " If dub is installed, start searching for the project root,
        " from the current source directory.
        let path = expand('%:p:h')
        let dubCommand = 'dub describe --import-paths'

        while 1
            if len(globpath(path, 'dub.json')) > 0 || len(globpath(path, 'dub.sdl')) > 0 || len(globpath(path, 'package.json')) > 0
                " We hit a directory with a dub package file.
                " Run the command to find the paths.
                let dubPaths = split(system('cd ' . shellescape(path) . ' && ' . dubCommand), '\n')

                if v:shell_error
                    " The dub command failed, so clear the captured output.
                    " Otherwise, we will capture some garbage.
                    let dubPaths = []
                endif

                break
            endif

            let nextPath = fnamemodify(path, ':h')

            if path == nextPath
                " We just checked a root directory, so stop here.
                break
            endif

            " Go up one directory.
            let path = nextPath
        endwhile
    endif

    if len(dubPaths) > 0
        " We found the exact import paths through DUB, so use those.
        return dubPaths
    endif

    " Fall back on using DMD to find import paths.
    return syntastic#c#GetLocList('d', 'dmd', {
        \ 'errorformat':
        \     '%-G%f:%s:,%f(%l): %m,' .
        \     '%f:%l: %m',
        \ 'main_flags': '-c -of' . syntastic#util#DevNull(),
        \ 'header_names': '\m\.di$' })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'd',
    \ 'name': 'dmd' })

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
