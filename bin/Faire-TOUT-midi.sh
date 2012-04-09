#!/bin/bash

R="/var/www/MUSIC"

cd $R

# for REP in Divers-Irlandais Jigs Reels
for REP in Divers-Irlandais Hornpipes Jigs Reels
do
        echo $REP
	cd $REP
	midi2mp3.sh
	cd $R
done

