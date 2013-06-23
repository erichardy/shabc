#!/bin/bash

export PATH="/opt/local/shabc/bin:$PATH"

if [ $# -lt 1 ]
then
	R="/var/wwwMUSIC/MUSIC"
else
	R=$1
fi

cd $R
git pull

for REP in Divers-Irlandais Hornpipes Jigs Reels
do
        echo $REP
	cd $REP
	FaireHTML.sh
	cd $R
done
