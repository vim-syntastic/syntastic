"============================================================================
"File:        glsl.vim
"Description: Syntax checker for OpenGL Shading Language
"Maintainer:  Joshua Rahm <joshuarahm@gmail.com>
"Notes:       Add the special comment line "// profile: " somewhere in the file
"             Followed by what profile to use for the cgc compiler when
"             checking the file. The defalt behavior is to pick the profile
"             based on the entries of dictionary g:syntastic_glsl_extensions
"             or a default dictionary if that variable does not exist
"             Use the variable g:syntastic_glsl_extra_args to specify extra
"             arguments to pass to the cgc compiler
"License:     This program is free software. It comes without any warranty,
"             to the extent permitted by applicable law. You can redistribute
"             it and/or modify it under the terms of the Do What The Fuck You
"             Want To Public License, Version 2, as published by Sam Hocevar.
"             See http://sam.zoy.org/wtfpl/COPYING for more details.
"
"============================================================================


if exists("g:loaded_syntastic_glsl_cgc_checker")
    finish
endif

let g:loaded_syntastic_glsl_cgc_checker=1

function! SyntaxCheckers_glsl_cgc_checker_IsAvailable() dict
    return executable(self.getExec());
endfunction

function! SyntaxCheckers_glsl_cgc_checker_GetProfile()
    let magic = '^// profile: '
    let line = search( magic, 'n' )

    if line
        let profile = substitute( getline(line), magic, '', '' ) 
        return profile
    endif

    if exists('g:syntastic_glsl_extensions')
        let profiles = g:syntastic_glsl_cgc_profiles
    else
        let profiles = {
            \ 'glslf': 'gpu_fp',
            \ 'glslv': 'gpu_vp',
            \ 'frag':  'gpu_fp',
            \ 'vert':  'gpu_vp',
            \ 'fp':    'gpu_fp',
            \ 'vp':    'gpu_vp' }
    endif


    let ext = expand('%:e')

    if has_key(profiles, ext)
        return profiles[ext]
    else
        return 'gpu_vert'
    endif
endfunction!

function! SyntaxCheckers_glsl_cgc_GetExtraArgs()
    if exists('g:syntastic_glsl_extra_args')
        return g:syntastic_glsl_extra_args
    else
        return ''
    endif
endfunction

function! SyntaxCheckers_glsl_cgc_GetLocList() dict
    let profile = SyntaxCheckers_glsl_cgc_checker_GetProfile()

    let args = printf("-oglsl -profile %s %s", profile,SyntaxCheckers_glsl_cgc_GetExtraArgs())
    let makeprg = self.makeprgBuild({
        \'args': args })

    echo makeprg
    let errorformat =
        \ "%E%f(%l) : error %m," .
        \ "%W%f(%l) : warning %m"

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \'filetype': 'glsl',
    \'name': 'cgc'})
