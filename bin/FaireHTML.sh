#!/bin/bash

HTML="index.html"
rm -f ${HTML}
HTML1="/opt/local/shabc/etc/HTML1.html"
HTML2="/opt/local/shabc/etc/HTML2.html"


function MakeMakefile {
	ABCFILE=$1
	MIDIFILE=$2
	PSFILE=$3
	MP3=$4
	PNG=$5
	echo "" > Makefile
	echo "" >> Makefile
	echo "$MIDIFILE: $ABCFILE" >> Makefile
	echo "	abc2midi $ABCFILE" >> Makefile
	echo "" >> Makefile
	echo "$PSFILE: $ABCFILE" >> Makefile
	if [ -f ${FMTFILE}.fmt ]
	then
		echo "	abcm2ps ${ABCFILE} -F $FMTFILE -O ${PSFILE}" >> Makefile
	else
		echo "	abcm2ps ${ABCFILE} -O ${PSFILE}" >> Makefile
	fi
	echo "" >> Makefile
	echo "$MP3: $ABCFILE" >> Makefile
	echo "	midi2mp3.sh $ABCFILE" >> Makefile
	echo "" >> Makefile
	echo "$PNG: $PSFILE" >> Makefile
	echo "	convert ${PSFILE} -filter Catrom  -resize 600 $PNG" >> Makefile
	echo "" >> Makefile
	echo "$PDF: $PSFILE" >> Makefile
	echo "	ps2pdf ${PSFILE}" >> Makefile
	echo "" >> Makefile
}

cat $HTML1 > $HTML
echo "<option value=\"\">Choisir un morceau</option>" >> $HTML

for ABC in `ls *.abc`
do
  BASE=`basename $ABC .abc`
  PSFILE=${BASE}.ps
  MID=${BASE}1.mid
  MP3=${BASE}1.mp3
  PNG=${BASE}.png
  PDF=${BASE}.pdf
  rm -f ${BASE}-*.png
  MakeMakefile $ABC $MID $PSFILE $MP3 $PNG $PDF
  # abcm2ps $ABC -O ${PSFILE}
  # convert ${PSFILE} -filter Catrom  -resize 600 $PNG
  make $PSFILE
  make $MID
  make $MP3
  make $PNG
  make $PDF
  if [ -f ${BASE}-0.png ]
  then
	montage -mode Concatenate ${BASE}-*.png  -tile 1 ${PNG}
  fi
  echo "<option value=\"$ABC\">$ABC</option>" >> $HTML
done
cat $HTML2 >> $HTML

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
	MIDI=${BASE}1.mid
	MP3=${BASE}1.mp3
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
