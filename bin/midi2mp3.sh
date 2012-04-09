#!/bin/sh

ABC=$1

if [ ! -f $ABC ]
then
	echo "$ABC n'existe pas... Sortie"
	exit 1
fi

FICH=`basename $ABC .abc`
MID="${FICH}1.mid"

if  [ ! -f ${MID} ]
then
	abc2midi ${ABC}
fi

echo "$MID : $FICH"
timidity -A 400 -EFchorus=2,50 -EFreverb=2 $MID -Oa 
AIFF="${FICH}1.aiff"
MP3="${FICH}1.mp3"
lame --cbr -b 32 -f --quiet ${AIFF} ${MP3}
mp3info -t $FICH -y `date '+%Y'` -a 'Eric Hardy' ${MP3}
rm -f ${AIFF}
exit

for MID in `ls *.mid`
do    
	# timidity -A 400 -EFchorus=2,50 -EFreverb=2  FatherKelly1.mid -Oa    
	# lame FatherKelly1.aiff FatherKelly1.mp3    FICH=`basename $MID .mid`
	echo "$MID : $FICH"
	timidity -A 400 -EFchorus=2,50 -EFreverb=2 $MID -Oa
	lame --cbr -b 32 -f --quiet $FICH.aiff $FICH.mp3
	mp3info -t $FICH -y `date '+%Y'` -a 'Eric Hardy' $FICH.mp3
	rm -r *.aiff
done
