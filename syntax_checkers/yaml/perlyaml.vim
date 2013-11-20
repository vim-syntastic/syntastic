"============================================================================
"File:        yaml.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Colin Keith <ckeith at cpan dot org>
"License:     Apache 2
"
"Installation: $ cpanm YAML
"
"============================================================================

if exists("g:loaded_syntastic_yaml_perlyaml_checker")
    finish
endif
let g:loaded_syntastic_yaml_perlyaml_checker=1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_yaml_perlyaml_IsAvailable() dict
    if exists("g:syntastic_yaml_perlyaml_haveperl")
        return g:syntastic_yaml_perlyaml_haveperl
    endif

    let v:errmsg = ''
    silent! execute "!/usr/bin/env perl -MYAML -e 'exit(1);'"
    if v:errmsg != ''
      let v:errmsg = "Eror loading /usr/bin/env perl -MYAML"
      return 0
    endif

    let g:syntastic_yaml_perlyaml_haveperl = 1
    return 1
endfunction

function! SyntaxCheckers_yaml_perlyaml_Preprocess(errors)
    let tmp = []

    let errors = []
    while !empty(a:errors)
      let an_error = a:errors[0:4]
      let tmp += [ join(an_error, '') ]
      try
        call remove(a:errors, 0, 5)
      catch /.*/
        break
      endtry
    endwhile

    let out = []
    for e in tmp
        let parts = matchlist(e, '\v^YAML Error: (.+) +Code: ([A-Z0-9_]+) +Line: ([0-9]+) +Document: (.+)$')
        if !empty(parts)
            let lineno = parts[3]
            call add(out, syntastic#util#shexpand('%') . ':' . lineno . ':' . parts[1] . parts[2])
        endif
    endfor

    return syntastic#util#unique(out)
endfunction

function! SyntaxCheckers_yaml_perlyaml_GetLocList() dict
    let fname      = shellescape(syntastic#util#shexpand('%'))
    let yamlscript = shellescape('YAML::LoadFile($ARGV[0]);exit(0)')
    " let yamlscript = shellescape('print "YAML Error: Err text\n   Code: ERROR_ABC\n   Line: 27\n   Document: 1\n"')
    let args       = 'perl -MYAML -e ' . yamlscript . ' ' . fname

    let makeprg = self.makeprgBuild({
                \ 'exe': '/usr/bin/env',
                \ 'args': args })
"                " \ 'post_args': '--more --args',
"                " \ 'tail': '> /tmp/output' })

    " YAML Error: Inconsistent indentation level
    "    Code: YAML_PARSE_ERR_INCONSISTENT_INDENTATION
    "    Line: 40
    "    Document: 1
    "  at /home/colin/perl5/lib/perl5/YAML/Loader.pm line 719.

    " We preprocess this to get errorformat below:
    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': '%f:%l:%m',
        \ 'preprocess': 'SyntaxCheckers_yaml_perlyaml_Preprocess',
        \ 'returns': [0, 2],
        \ })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'yaml',
    \ 'name': 'perlyaml'
    \ })

let &cpo = s:save_cpo
unlet s:save_cpo
