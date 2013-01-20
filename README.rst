shabc
=====

shabc (shabc.sh) is a shell script useful for me when I want to use UNIX command line tools as abc2midi, abc2mps and abc2abc.

The original development (at least 15 years ago) was made under Linux, but since I use an Apple computer at home, I modified it for this platform.

Some features are :

- the interface is fully oriented keyboard with shortcuts

- it is possible to manage series independently of the location of the tunes on the filesystem

- when you quit the application, the last tune is saved so you retreve it next time you open it

- under MacOSX, the view and the playing are processed with safari. In the Linux version, timidity and a ghoscript viewer were used for those purposes. Traces of Linux version remains in the code.

NB: as I'm french, the interface is in french... sorry...

I often use my application when I learn or re-learn Irish tunes.

The script FaireHTML.sh is used under a Linux/apache2 server to generate web interface of my set of tunes.

TODO
====
- manage scores on multiple pages in function grouper_Tout (bin/shabc.sh)
  montage  -mode Concatenate ABCIMG-0.png ABCIMG-1.png -tile 1 ABCIMG.png
- DONE (in FaireHTML.sh, not in javascript) : manage scores on multiple pages in javascript function function morceauHTML in etc/HTML1.html

