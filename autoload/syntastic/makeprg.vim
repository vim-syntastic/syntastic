if exists("g:loaded_syntastic_makeprg_autoload")
    finish
endif
let g:loaded_syntastic_makeprg_autoload = 1

function! syntastic#makeprg#build(opts)
    let opts = copy(a:opts)

    if !has_key(opts, 'args')
        let opts['args'] = ''
    endif

    if !has_key(opts, 'subchecker')
        let opts['subchecker'] = ''
    endif

    let builder = s:MakeprgBuilder.New(opts['exe'], opts['args'], opts['subchecker'])
    return builder.makeprg()
endfunction

let s:MakeprgBuilder = {}

function! s:MakeprgBuilder.New(exe, args, subchecker)
    let newObj = copy(self)
    let newObj._exe = a:exe
    let newObj._args = a:args
    let newObj._subchecker = a:subchecker
    return newObj
endfunction

function! s:MakeprgBuilder.makeprg()
    return join([self.exe(), self.args(), self.fname()])
endfunction

function! s:MakeprgBuilder.exe()
    if self.optExists('exe')
        return {self.optName('exe')}
    endif

    return self._exe
endfunction

function! s:MakeprgBuilder.args()
    if exists('g:syntastic_' . &ft . '_args')
        return g:syntastic_{&ft}_args
    endif

    return self._args
endfunction

function! s:MakeprgBuilder.fname()
    return shellescape(expand("%"))
endfunction

function! s:MakeprgBuilder.optExists(name)
    return exists(self.optName(a:name))
endfunction

function! s:MakeprgBuilder.optName(name)
    let setting = "g:syntastic_" . &ft
    if !empty(self._subchecker)
        let setting .= '_' . self._subchecker
    endif
    return setting . '_' . a:name
endfunction
