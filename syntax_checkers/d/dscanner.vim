"============================================================================
"File:        dscanner.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  ANtlord
"License:     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
"             EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
"             OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
"             NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
"             HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
"             WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
"             FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
"             OTHER DEALINGS IN THE SOFTWARE.
"
"============================================================================

if exists('g:loaded_syntastic_d_dscanner_checker')
    finish
endif
let g:loaded_syntastic_d_dscanner_checker = 1

if !exists('g:syntastic_d_dscanner_sort')
    let g:syntastic_d_dscanner_sort = 1
endif

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_d_dscanner_IsAvailable() dict
    let exec = self.getExec()
    echo exec
    let res = executable(exec)
    echo res
    return res
endfunction

function! SyntaxCheckers_d_dscanner_GetLocList() dict
    if !has('python3')
        echo "Syntastic: Python3 support is necessary for dscanner."
        finish
    endif
    let makeprg = self.makeprgBuild({
                \ 'args': '--report',
                \ 'args_after': '' })
py3 << EOF
import vim
import subprocess as sp
import json
filename = vim.current.buffer.name
buffernumber = vim.current.buffer.number
command = vim.eval('makeprg').split()
result = sp.run(command, stdout=sp.PIPE, stderr=sp.DEVNULL)
output = result.stdout.decode().replace('\n', '')

json_start = output.find('{')

output_for_json = output[json_start:]
error_data = json.loads(output_for_json)
issues = error_data['issues']

messages = []
for issue in issues:
    messages.append({
        'bufnr': buffernumber,
        'lnum': issue['line'],
        'col': issue['column'],
        'nr': -1,
        'text': issue['message'],
        'type': 'error',
        'valid': 1
    })
 
vim.command('let result = %s' % messages)
EOF
    return result
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
            \ 'filetype': 'd',
            \ 'name': 'dscanner',
            \ 'exec': 'dscanner' })

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=4 sts=4 et fdm=marker:
