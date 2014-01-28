if exists("g:loaded_syntastic_makeprg_builder")
    finish
endif
let g:loaded_syntastic_makeprg_builder = 1

let g:SyntasticMakeprgBuilder = {}

" Public methods {{{1

function! g:SyntasticMakeprgBuilder.Instance()
    if !exists('s:SyntasticMakeprgBuilderInstance')
        let s:SyntasticMakeprgBuilderInstance = copy(self)
    endif
    return s:SyntasticMakeprgBuilderInstance
endfunction

function! g:SyntasticMakeprgBuilder.makeprg(checker, opts)
    if has_key(a:checker, 'getName')
        let filetype = a:checker.getFiletype()
        let subchecker = a:checker.getName()
    else
        let filetype = &filetype
        let subchecker = ''
    endif
    let setting = 'g:syntastic_' . filetype
    if strlen(subchecker)
        let setting .= '_' . subchecker . '_'
    endif

    let parts = self._getOpt(a:opts, setting, 'exe', has_key(a:checker, 'getExec') ? a:checker.getExec() : '')
    call extend(parts, self._getOpt(a:opts, setting, 'args', ''))
    call extend(parts, self._getOpt(a:opts, setting, 'fname', syntastic#util#shexpand('%')))
    call extend(parts, self._getOpt(a:opts, setting, 'post_args', ''))
    call extend(parts, self._getOpt(a:opts, setting, 'tail', ''))

    return join(filter(parts, 'strlen(v:val)'))
endfunction

" Private methods {{{1

function! g:SyntasticMakeprgBuilder._getOpt(opts, setting, name, default)
    return [
        \ get(a:opts, a:name . '_before', ''),
        \ self._getOptUser(a:opts, a:setting, a:name, a:default),
        \ get(a:opts, a:name . '_after', '') ]
endfunction

function! g:SyntasticMakeprgBuilder._getOptUser(opts, setting, name, default)
    let sname = a:setting . a:name
    if exists(sname)
        return {sname}
    endif

    return get(a:opts, a:name, a:default)
endfunction

" vim: set sw=4 sts=4 et fdm=marker:
