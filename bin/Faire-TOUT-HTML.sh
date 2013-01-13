#!/bin/bash

# export PATH="/opt/local/bin:$PATH"

R="/var/www/MUSIC"

cd $R

for REP in Divers-Irlandais Hornpipes Jigs Reels
do
        echo $REP
	cd $REP
	FaireHTML.sh
	cd $R
done
