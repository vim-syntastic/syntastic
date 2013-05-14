"============================================================================
"File:        javac.vim
"Description: Syntax checking plugin for syntastic.vim
"Maintainer:  Jochen Keil <jochen.keil at gmail dot com>
"             Dmitry Geurkov <d.geurkov at gmail dot com>
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================

if exists("g:loaded_syntastic_java_javac_checker")
    finish
endif
let g:loaded_syntastic_java_javac_checker=1

" Global Options
if !exists("g:syntastic_java_javac_executable")
    let g:syntastic_java_javac_executable = 'javac'
endif

if !exists("g:syntastic_java_maven_executable")
    let g:syntastic_java_maven_executable = 'mvn'
endif

if !exists("g:syntastic_java_javac_options")
    let g:syntastic_java_javac_options = '-Xlint'
endif

if !exists("g:syntastic_java_javac_classpath")
    let g:syntastic_java_javac_classpath = ''
endif

if !exists("g:syntastic_java_javac_delete_output")
    let g:syntastic_java_javac_delete_output = 1
endif

function! s:CygwinPath(path)
    return substitute(system("cygpath -m ".a:path), '\%x00', '', 'g')
endfunction

if !exists("g:syntastic_java_javac_temp_dir")
    if has('win32') || has('win64')
        let g:syntastic_java_javac_temp_dir = $TEMP."\\vim-syntastic-javac"
    elseif has('win32unix')
        let g:syntastic_java_javac_temp_dir = s:CygwinPath('/tmp/vim-syntastic-javac')
    else
        let g:syntastic_java_javac_temp_dir = '/tmp/vim-syntastic-javac'
    endif
endif

if !exists("g:syntastic_java_javac_autoload_maven_classpath")
    let g:syntastic_java_javac_autoload_maven_classpath = 1
endif

if !exists('g:syntastic_java_javac_config_file_enabled')
    let g:syntastic_java_javac_config_file_enabled = 0
endif

if !exists('g:syntastic_java_javac_config_file')
    let g:syntastic_java_javac_config_file = '.syntastic_javac_config'
endif

" Internal variables, do not ovveride those
if !exists("g:syntastic_java_javac_maven_pom_cwd")
    let g:syntastic_java_javac_maven_pom_cwd = ''
endif

if !exists("g:syntastic_java_javac_maven_pom_ftime")
    let g:syntastic_java_javac_maven_pom_ftime = 0
endif

if !exists("g:syntastic_java_javac_maven_pom_classpath")
    let g:syntastic_java_javac_maven_pom_classpath = ''
endif

function! s:RemoveCarriageReturn(line)
    return substitute(a:line, '\r', '', 'g')
endfunction

" recursively remove directory and all it's sub-directories
function! s:RemoveDir(dir)
    if isdirectory(a:dir)
        for f in split(globpath(a:dir, '*'), "\n")
            call s:RemoveDir(f)
        endfor
        silent! call system('rmdir ' . a:dir)
    else
        silent! call delete(a:dir)
    endif
endfunction

function! s:AddToClasspath(classpath,path)
    if a:path == ''
        return a:classpath
    endif
    if a:classpath != '' && a:path != ''
        if has('win32') || has('win32unix') || has('win64')
            return a:classpath . ";" . a:path
        else
            return a:classpath . ":" . a:path
        endif
    else
        return a:path
    endif
endfunction

function! s:LoadClasspathFromConfigFile()
    if filereadable(g:syntastic_java_javac_config_file)
        let path = ''
        let lines = readfile(g:syntastic_java_javac_config_file)
        for l in lines
            if l != ''
                let path .= l . "\n"
            endif
        endfor
        return path
    else
        return ''
    endif
endfunction

function! s:SaveClasspath()
    let path = ''
    let lines = getline(1, line('$'))
    " save classpath to config file
    if g:syntastic_java_javac_config_file_enabled
        call writefile(lines,g:syntastic_java_javac_config_file)
    endif
    for l in lines
        if l != ''
            let path .= l . "\n"
        endif
    endfor
    let g:syntastic_java_javac_classpath = path
    let &modified = 0
endfunction

function! s:EditClasspath()
    let command = 'syntastic javac classpath'
    let winnr = bufwinnr('^' . command . '$')
    if winnr < 0
        let pathlist = split(g:syntastic_java_javac_classpath,"\n")
        execute (len(pathlist) + 5) . 'sp ' . fnameescape(command)

        augroup syntastic
            autocmd BufWriteCmd <buffer> call s:SaveClasspath() | bwipeout
        augroup END

        setlocal buftype=acwrite bufhidden=wipe nobuflisted noswapfile nowrap number
        for p in pathlist
            call append(line('$') - 1, p)
        endfor
    else
        execute winnr . 'wincmd w'
    endif
endfunction
command! SyntasticJavacEditClasspath call s:EditClasspath()

function! s:GetMavenClasspath()
    if filereadable('pom.xml')
        if g:syntastic_java_javac_maven_pom_ftime != getftime('pom.xml') || g:syntastic_java_javac_maven_pom_cwd != getcwd()
            let mvn_classpath_output = split(system(g:syntastic_java_maven_executable . ' dependency:build-classpath'), "\n")
            let class_path_next = 0

            for line in mvn_classpath_output
                if class_path_next == 1
                    let mvn_classpath = s:RemoveCarriageReturn(line)
                    break
                endif
                if match(line,'Dependencies classpath:') >= 0
                    let class_path_next = 1
                endif
            endfor

            let mvn_classpath = s:AddToClasspath(mvn_classpath, 'target/classes')
            let mvn_classpath = s:AddToClasspath(mvn_classpath, 'target/test-classes')

            let g:syntastic_java_javac_maven_pom_cwd = getcwd()
            let g:syntastic_java_javac_maven_pom_ftime = getftime('pom.xml')
            let g:syntastic_java_javac_maven_pom_classpath = mvn_classpath
        endif
        return g:syntastic_java_javac_maven_pom_classpath
    endif
    return ''
endfunction

function! SyntaxCheckers_java_javac_IsAvailable()
    return executable(g:syntastic_java_javac_executable)
endfunction

function! s:MavenOutputDirectory()
    if filereadable('pom.xml')
        let output_dir = getcwd()
        if match(expand( '%:p:h' ), "src.main.java") >= 0
            let output_dir .= '/target/classes'
        endif
        if match(expand( '%:p:h' ), "src.test.java") >= 0
            let output_dir .= '/target/test-classes'
        endif

        if has('win32unix')
            let output_dir=s:CygwinPath(output_dir)
        endif
        return output_dir
    endif
endfunction

function! SyntaxCheckers_java_javac_GetLocList()

    let javac_opts = g:syntastic_java_javac_options

    if g:syntastic_java_javac_delete_output
        let output_dir = g:syntastic_java_javac_temp_dir
        let javac_opts .= ' -d ' . output_dir
    endif

    " load classpath from config file
    if g:syntastic_java_javac_config_file_enabled
        let loaded_classpath = s:LoadClasspathFromConfigFile()
        if loaded_classpath != ''
            let g:syntastic_java_javac_classpath = loaded_classpath
        endif
    endif

    let javac_classpath = ''

    " add classpathes to javac_classpath
    for path in split(g:syntastic_java_javac_classpath,"\n")
        if path != ''
            try
                let ps = glob(path,0,1)
            catch
                let ps = split(glob(path,0),"\n")
            endtry
            if type(ps) == type([])
                for p in ps
                    if p != ''
                        let javac_classpath = s:AddToClasspath(javac_classpath,p)
                    endif
                endfor
            else
                let javac_classpath = s:AddToClasspath(javac_classpath,ps)
            endif
        endif
    endfor

    if g:syntastic_java_javac_autoload_maven_classpath
        if !g:syntastic_java_javac_delete_output
            let maven_output_dir = s:MavenOutputDirectory()
            let javac_opts .= ' -d ' . maven_output_dir
        endif
        let maven_classpath = s:GetMavenClasspath()
        let javac_classpath = s:AddToClasspath(javac_classpath,maven_classpath)
    endif

    if javac_classpath != ''
        let javac_opts .= ' -cp "' . fnameescape(javac_classpath) . '"'
    endif

    " path seperator
    if has('win32') || has('win32unix') || has('win64')
        let sep = "\\"
    else
        let sep = '/'
    endif

    let fname = fnameescape(expand ( '%:p:h' ) . sep . expand ( '%:t' ))

    if has('win32unix')
        let fname =  s:CygwinPath(fname)
    endif

    let makeprg = syntastic#makeprg#build({
        \ 'exe': g:syntastic_java_javac_executable,
        \ 'args': javac_opts,
        \ 'fname': fname,
        \ 'tail': '2>&1',
        \ 'subchecker': 'javac' })

    " unashamedly stolen from *errorformat-javac* (quickfix.txt) and modified to include error types
    let errorformat =
        \ '%E%f:%l:\ error:\ %m,'.
        \ '%W%f:%l:\ warning:\ %m,'.
        \ '%A%f:%l:\ %m,'.
        \ '%+Z%p^,'.
        \ '%+C%.%#,'.
        \ '%-G%.%#'

    if g:syntastic_java_javac_delete_output
        silent! call mkdir(output_dir,'p')
    endif
    let errors = SyntasticMake({ 'makeprg': makeprg, 'errorformat': errorformat, 'postprocess': ['cygwinRemoveCR'] })

    if g:syntastic_java_javac_delete_output
        call s:RemoveDir(output_dir)
    endif
    return errors

endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'java',
    \ 'name': 'javac'})

