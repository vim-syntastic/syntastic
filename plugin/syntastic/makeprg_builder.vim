if exists("g:loaded_syntastic_makeprg_builder")
    finish
endif
let g:loaded_syntastic_makeprg_builder = 1

let g:SyntasticMakeprgBuilder = {}

function! g:SyntasticMakeprgBuilder.New(exe, args, fname, post_args, tail, subchecker)
    let newObj = copy(self)
    let newObj._exe = a:exe
    let newObj._args = a:args
    let newObj._fname = a:fname
    let newObj._post_args = a:post_args
    let newObj._tail = a:tail
    let newObj._subchecker = a:subchecker
    return newObj
endfunction

function! g:SyntasticMakeprgBuilder.makeprg()
    return join([self.exe(), self.args(), self.fname(), self.post_args(), self.tail()])
endfunction

function! g:SyntasticMakeprgBuilder.exe()
    return self._getOpt('exe')
endfunction

function! g:SyntasticMakeprgBuilder.args()
    return self._getOpt('args')
endfunction

function! g:SyntasticMakeprgBuilder.fname()
    if empty(self._fname)
        return  shellescape(expand("%"))
    else
        return self._fname
    endif
endfunction

function! g:SyntasticMakeprgBuilder.post_args()
    return self._getOpt('post_args')
endfunction

function! g:SyntasticMakeprgBuilder.tail()
    return self._getOpt('tail')
endfunction

function g:SyntasticMakeprgBuilder._getOpt(name)
    if self._optExists(a:name)
        return {self._optName(a:name)}
    endif

    return self['_' . a:name]
endfunction

function! g:SyntasticMakeprgBuilder._optExists(name)
    return exists(self._optName(a:name))
endfunction

function! g:SyntasticMakeprgBuilder._optName(name)
    let setting = "g:syntastic_" . &ft
    if !empty(self._subchecker)
        let setting .= '_' . self._subchecker
    endif
    return setting . '_' . a:name
endfunction
