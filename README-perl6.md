# This is a temporary fork of syntastic with perl6 support (work in progress)

To enable perl6 lint support, add this to your ~/.vimrc:
```
let g:syntastic_enable_perl6_checker = 1
```
Beware, this uses 'perl6 -c' and therefor will run BEGIN and CHECK blocks.

To use this fork, backup your syntastic install, and link this repo to the old
place. In my case (a setup using pathogen):

```
$ mkdir ~/tmp
$ cp -rp ~/.vim/bundle/syntastic ~/tmp/
$ git clone https://github.com/nxadm/syntastic ~/.vim/bundle/synastic
```

Within vim, type :Helptags once.

The linter is by no means complete, but on my setup it shows most of the errors
at savetime.

syntastic installation information and minimal .vimrc setup:
https://github.com/nxadm/syntastic (fork with perl6 doc)
https://github.com/scrooloose/syntastic (upstream)

Short howto for Perl 6:
Add this to your .vimrc:
```
"syntastic syntax checking
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
"airline integration (commented)
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*
"Language specific configuration
"A comma separated list of paths to be included to -I
"let g:syntastic_perl6_lib_path = [ '/home/claudio/Code/OpenLDAP-DataConsistency/lib' ]
"You need to enable the perl6 checker
let g:syntastic_enable_perl6_checker = 1
```
There are two ways of dealing with unknown lib path perl6 errors, you can populate the g:syntastic_perl6_lib_path with default lib dirs, and/or more
practically set the PERL6LIB shell variable.

Once Perl 6 support is completed, a PR will be sent upstream. Post an issue
if you found Perl 6 syntax (compile) error not yet catched.

El_Che @ #perl6
