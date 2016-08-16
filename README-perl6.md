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

syntastic installation information and setup:
https://github.com/scrooloose/syntastic

Once the addition of Perl 6 support is completed, a PR will be sent iupstream.

El_Che @ #perl6
