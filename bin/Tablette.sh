#!/bin/sh

TABLETTE="/Users/hardy/Music/ABC/Tablette"
REP="/Users/hardy/Music/ABC/01-Irlande"
REPS="Jigs Divers-Irlandais Reels Hornpipes"
HTML="index.html"
rm -f ${HTML}
HTML1="/opt/local/shabc/etc/Tablette-HTML1.html"
HTML2="/opt/local/shabc/etc/Tablette-HTML2.html"

function MakeMakefile {
	ABCFILE=$1
	PSFILE=$2
	PNG=$3
	echo "" > Makefile
	echo "" >> Makefile
	echo "$PSFILE: $ABCFILE" >> Makefile
	if [ -f ${FMTFILE}.fmt ]
	then
		echo "	abcm2ps ${ABCFILE} -F $FMTFILE -O ${PSFILE}" >> Makefile
	else
		echo "	abcm2ps ${ABCFILE} -O ${PSFILE}" >> Makefile
	fi
	echo "" >> Makefile
	echo "$PNG: $PSFILE" >> Makefile
	echo "	convert ${PSFILE} -filter Catrom  -resize 600 $PNG" >> Makefile
	echo "" >> Makefile
}
function MakeHTML {
	cat $HTML1 > $HTML
	echo "<option value=\"\">Choisir un morceau</option>" >> $HTML

	for ABC in `ls *.abc`
	do
	  BASE=`basename $ABC .abc`
	  PSFILE=${BASE}.ps
	  PNG=${BASE}.png
	  MakeMakefile $ABC $PSFILE $PNG
	  # abcm2ps $ABC -O ${PSFILE}
	  # convert ${PSFILE} -filter Catrom  -resize 600 $PNG
	  make $PSFILE
	  make $PNG
	  echo "<option value=\"$ABC\">$ABC</option>" >> $HTML
	done
	cat $HTML2 >> $HTML
}

cd $REP

rm -f Files
find $REPS -depth 1 -name '*.abc' > Files
rsync -avRd --files-from=./Files . $TABLETTE
for R in $REPS
do
	echo $R
	cd $TABLETTE/$R
	MakeHTML
done
exit


exit

HTML="index.html"
rm -f ${HTML}
echo "<html> <head>  <meta name="pragma" CONTENT="no-cache"> <title> ${TITRE} </title> </head> <body>" > ${HTML}
echo "<center><h1></h1></center>" >> ${HTML}

for ABC in `ls *.abc`
do
	echo $ABC
	BASE=`basename $ABC .abc`
	echo $BASE
	VITESSE=`grep '^Q:' ${ABC} | awk '{print $2}' FS=":"`
	PARTIES=`grep '^P:' ${ABC} | head -1 | awk '{print $2}' FS=":"`
	IMG=${BASE}.png
	echo "
	<h2>${ABC}</h2>
	Vitesse = ${VITESSE}<br />
	Parties = ${PARTIES}<br />
	<object>
	<embed height=\"30\" autostart=false src=\"file:${MP3}\">
	</embed>
	</object>
	<br />
	<img src=\"$IMG\">" >> index.html

done

exit

