if exists("g:loaded_syntastic_makeprg_autoload")
    finish
endif
let g:loaded_syntastic_makeprg_autoload = 1

"Returns a makeprg of the form
"
"[exe] [args] [filename] [post_args] [tail]
"
"A (made up) example:
"    ruby -a -b -c test_file.rb --more --args > /tmp/output
"
"To generate this you would call:
"
"    let makeprg = syntastic#makeprg#build({
"                \ 'exe': 'ruby',
"                \ 'args': '-a -b -c',
"                \ 'post_args': '--more --args',
"                \ 'tail': '> /tmp/output',
"                \ 'subchecker': 'mri' })
"
"Note that the current filename is added by default - but can be overridden by
"passing in an 'fname' arg.
"
"All options can be overriden by the user with global variables - even when
"not specified by the checker in syntastic#makeprg#build().
"
"E.g. They could override the checker exe with
"
"   let g:syntastic_ruby_mri_exe="another_ruby_checker_exe.rb"
"
"The general form of the override option is:
"   syntastic_[filetype]_[subchecker]_[option-name]
"
function! syntastic#makeprg#build(opts)
    let builder = s:MakeprgBuilder.New(
                \ get(a:opts, 'exe', ''),
                \ get(a:opts, 'args', ''),
                \ get(a:opts, 'fname', ''),
                \ get(a:opts, 'post_args', ''),
                \ get(a:opts, 'tail', ''),
                \ get(a:opts, 'subchecker', '') )

    return builder.makeprg()
endfunction

let s:MakeprgBuilder = {}

function! s:MakeprgBuilder.New(exe, args, fname, post_args, tail, subchecker)
    let newObj = copy(self)
    let newObj._exe = a:exe
    let newObj._args = a:args
    let newObj._fname = a:fname
    let newObj._post_args = a:post_args
    let newObj._tail = a:tail
    let newObj._subchecker = a:subchecker
    return newObj
endfunction

function! s:MakeprgBuilder.makeprg()
    return join([self.exe(), self.args(), self.fname(), self.post_args(), self.tail()])
endfunction

function! s:MakeprgBuilder.exe()
    return self._getOpt('exe')
endfunction

function! s:MakeprgBuilder.args()
    return self._getOpt('args')
endfunction

function! s:MakeprgBuilder.fname()
    if empty(self._fname)
        return  shellescape(expand("%"))
    else
        return self._fname
    endif
endfunction

function! s:MakeprgBuilder.post_args()
    return self._getOpt('post_args')
endfunction

function! s:MakeprgBuilder.tail()
    return self._getOpt('tail')
endfunction

function s:MakeprgBuilder._getOpt(name)
    if self._optExists(a:name)
        return {self._optName(a:name)}
    endif

    return self['_' . a:name]
endfunction

function! s:MakeprgBuilder._optExists(name)
    return exists(self._optName(a:name))
endfunction

function! s:MakeprgBuilder._optName(name)
    let setting = "g:syntastic_" . &ft
    if !empty(self._subchecker)
        let setting .= '_' . self._subchecker
    endif
    return setting . '_' . a:name
endfunction
