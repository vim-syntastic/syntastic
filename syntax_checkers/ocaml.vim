"============================================================================
"File:        ocaml.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Török Edwin <edwintorok at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================
"
" The more reliable way to check for a single .ml file is to use ocamlc.
" You can do that setting this in your .vimrc:
"
"   let g:syntastic_ocaml_use_ocamlc = 1
" It's possible to use ocamlc in conjuction with Jane Street's Core. In order
" to do that, you have to specify this in your .vimrc:
"
"   let g:syntastic_ocaml_use_janestreet_core = 1
"   let g:syntastic_ocaml_janestreet_core_dir = <path>
"
" Where path is the path to your core installation (usually a collection of
" .cmx and .cmxa files).
"
"
" By default the camlp4o preprocessor is used to check the syntax of .ml, and .mli files,
" ocamllex is used to check .mll files and menhir is used to check .mly files.
" The output is all redirected to /dev/null, nothing is written to the disk.
"
" If your source code needs camlp4r then you can define this in your .vimrc:
"
"   let g:syntastic_ocaml_camlp4r = 1
"
" If you used some syntax extensions, or you want to also typecheck the source
" code, then you can define this:
"
"   let g:syntastic_ocaml_use_ocamlbuild = 1
"
" This will run ocamlbuild <name>.inferred.mli, so it will write to your _build
" directory (and possibly rebuild your myocamlbuild.ml plugin), only enable this
" if you are ok with that.
"
" If you are using syntax extensions / external libraries and have a properly
" set up _tags (and myocamlbuild.ml file) then it should just work
" to enable this flag and get syntax / type checks through syntastic.
"
" For best results your current directory should be the project root
" (same situation if you want useful output from :make).

if exists("loaded_ocaml_syntax_checker")
    finish
endif
let loaded_ocaml_syntax_checker = 1

if exists('g:syntastic_ocaml_camlp4r') &&
    \ g:syntastic_ocaml_camlp4r != 0
    let s:ocamlpp="camlp4r"
else
    let s:ocamlpp="camlp4o"
endif

"bail if the user doesnt have the preprocessor
if !executable(s:ocamlpp)
    finish
endif

function! SyntaxCheckers_ocaml_GetLocList()
    if exists('g:syntastic_ocaml_use_ocamlc') &&
                \ g:syntastic_ocaml_use_ocamlc != 0 &&
                \ executable("ocamlc")
        if exists('g:syntastic_ocaml_use_janestreet_core') &&
                    \ g:syntastic_ocaml_use_janestreet_core != 0
            let makeprg = "ocamlc -I ". shellescape(expand(g:syntastic_ocaml_janestreet_core_dir)) ." -c ".shellescape(expand('%'))
        else
            let makeprg = "ocamlc -c ".shellescape(expand('%'))
        endif
    else
        if exists('g:syntastic_ocaml_use_ocamlbuild') &&
                    \ g:syntastic_ocaml_use_ocamlbuild != 0 &&
                    \ executable("ocamlbuild") &&
                    \ isdirectory('_build')
            let makeprg = "ocamlbuild -quiet -no-log -tag annot,". s:ocamlpp. " -no-links -no-hygiene -no-sanitize ".
                        \ shellescape(expand('%:r')).".cmi"
        else
            let extension = expand('%:e')
            if match(extension, 'mly') >= 0
                " ocamlyacc output can't be redirected, so use menhir
                if !executable("menhir")
                    return []
                endif
                let makeprg = "menhir --only-preprocess ".shellescape(expand('%')) . " >/dev/null"
            elseif match(extension,'mll') >= 0
                if !executable("ocamllex")
                    return []
                endif
                let makeprg = "ocamllex -q -o /dev/null ".shellescape(expand('%'))
            else
                let makeprg = "camlp4o -o /dev/null ".shellescape(expand('%'))
            endif
        endif
    endif
    let errorformat = '%AFile "%f"\, line %l\, characters %c-%*\d:,'.
                \ '%AFile "%f"\, line %l\, characters %c-%*\d (end at line %*\d\, character %*\d):,'.
                \ '%AFile "%f"\, line %l\, character %c:,'.
                \ '%AFile "%f"\, line %l\, character %c:%m,'.
                \ '%-GPreprocessing error %.%#,'.
                \ '%-GCommand exited %.%#,'.
                \ '%C%tarning %n: %m,'.
                \ '%C%m,'.
                \ '%-G+%.%#'

    return SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat })
endfunction
