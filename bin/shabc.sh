#!/bin/bash

# set -v
# set -x
# shabc : Version 0.1
PROGRAMME=$0
# BINDIR=${HOME}/bin
BINDIR=/opt/local/shabc/bin
SHABC_VERSION="0.1"
TIMIDITY_EFFECTS=" -EFchorus=2,50 -EFreverb=2 "
FORCE="yes"

# lecture du fichier de définition des couleurs
. $BINDIR/shabc_couleurs.sh

# lecture du script de fonctions de gestion des tableaux
# utiles pour la gestion desx séries
. $BINDIR/shabc_tableau.sh

# lecture du scrip des fonctions de gestion de l'historique général
. $BINDIR/shabc_hist.sh

# lecture du script des fonctions de changement des paramètres
. $BINDIR/shabc_divers.sh

# lecture du script des fcontions de gestion des séries
. $BINDIR/shabc_series.sh

# Vérification de la présence des utilitaires indispensables
# UTILITAIRES="readc abc2midi abc2ps gv timidity"
UTILITAIRES="abc2midi abc2ps gv timidity"

for UTIL in `echo $UTILITAIRES`
do
	U=`which $UTIL`
	# echo "\$U = $U"
	if [ ! -x "$U" ]
	then
		echo -e "La commande ${_R}${UTIL}${_N} n'est pas accessible"
		echo "Sortie"
		# sleep 3
		exit
	fi
done

# vérification des fichiers et répertoires d'initialisation
# dans le répertoire HOME de l'Utilisateur
# fichier : $HOME/.shabc
# répertoire : $HOME/.shabc_series
INIT=$HOME/.shabc
SERIES=$HOME/.shabc_series

if [ ! -r ${INIT} ]
then
	stty erase 
	echo -en "Création du fichier d'initialisattion ${INIT} (Y/n) : "
	read REPONSE
	case ${REPONSE:='y'} in
		Y|y) .  $BINDIR/shabc_init.sh Init
			;;
		*) echo -e "Le programme ${_V}$0${_N} ne peut fonctionner"
		   echo "sans fichier d'initialisation !"
			echo -e "${_R}Sortie${_N}"
			# sleep 3
			exit
			;;
	esac
fi

if [ ! -d ${SERIES} ]
then
	echo "Création du répertoire des séries : ${SERIES}"
	. $BINDIR/shabc_init.sh Rep_series
fi


# lecture du fichier d'initialisation $INIT
function shabc_init {
	. $INIT
	ABCFILE=${MORCEAU}.abc
	PSFILE=${MORCEAU}.ps
	EPSFILE=${MORCEAU}.eps
	MIDIFILE=${MORCEAU}1.mid
	FMTFILE=${MORCEAU}
	serie_courante
}

shabc_init
cd $PWD

function ChInit {
	. $BINDIR/shabc_init.sh Refaire
	shabc_init
	Usage
}

function ChInit2 {
	. $BINDIR/shabc_init.sh Refaire
	shabc_init
}

function Warning {
if [ ! -f "$PWD/$ABCFILE" ]
then
	rouge "======================================================" ; echo
	rouge "ATTENTION : le fichier $ABCFILE n'est pas présent" ; echo
	rouge "            dans le répertoire courrant : $PWD" ; echo
	rouge "======================================================" ; echo
else
	cd $PWD
	VITESSE=`grep '^Q:' ${ABCFILE} | awk '{print $2}' FS=":"`
	PARTIES=`grep '^P:' ${ABCFILE} | head -1 | awk '{print $2}' FS=":"`
fi
}

function Autres_commandes {
	local AZE
	clear
	jaune "=============================================================" ; echo
	echo -e "        N : ${_M}N${_N}ouvelle série (création)"
	echo -e "        c : ${_M}c${_N}harger une série existante"
	echo -e "        I : ${_M}I${_N}nsérer ${_V}${ABCFILE}${_N} dans la série"
	echo -e "        l : ${_M}l${_N}es morceaux de la série (pour en choisir un)"
	jaune "=============================================================" ; echo
	echo -e "        a : ${_M}a${_N}utre morceau        r : nouveau ${_M}r${_N}épertoire"
	echo -e "        t : ${_M}t${_N}ransposition de ${_V}n${_N} demitons de ${ABCFILE}"
	echo -e "        M : construction de ${_M}M${_N}akefile"
	echo -e "        L : ${_M}L${_N}es fichiers abc dans ${_G}${PWD}${_N}"
	echo -e "        h : ${_M}h${_N}istorique des ${NB_HIST} précédents morceaux"
	echo -e "        H : Mise à jour de l'${_M}H${_N}istorique des ${NB_HIST} précédents morceaux"
	jaune "=============================================================" ; echo
	echo -n "appuyer sur une touche pour revenir au menu principal "
	AZE=`readc`
	clear
	Usage
}

function Usage {
	clear
	# echo ""
	Warning
	jaune "=============================================================" ; echo
	echo -e "Usage : q|Q : ${_M}Q${_N}uitter       ? : autres commandes"
	echo -e "          s : Gestion de la ${_M}s${_N}érie ${_V}${SERIE}${_N} ($TAILLESERIE)"
	# echo "        M : Makefile"
	echo -e "          g : re${_M}G${_N}rouper la série dans un seul fichier de partitions"
	echo -e "          T : regrouper ${_M}T${_N}ous les morceaux du répertoire courant"
	echo -e "          d : ${_M}d${_N}ivers paramètres    S : gestion des ${_M}S${_N}éries"
	jaune "=============================================================" ; echo
	echo -e "        i : Contruction du fichier M${_M}i${_N}d${_M}i${_N}"
	echo -e "        p : Contruction du fichier ${_M}P${_N}ostscript"
	echo -e "        P : voir la ${_M}P${_N}artition"
	echo -e "      e|é : ${_M}é${_N}diter ${_V}${ABCFILE}${_N}"
	echo -e "        v : changer la ${_M}v${_N}itesse (Vitesse = ${VITESSE})"
	echo -e "      0|j : ${_M}j${_N}ouer ${_V}${ABCFILE}${_N} (Ampli = ${AMPLI})"
	jaune "=============================================================" ; echo
	echo -n " Morceau : " ; vert "$ABCFILE" ; echo
	echo -n " Répertoire : " ; vert "$PWD" ; echo
	jaune "=============================================================" ; echo
}

function Chfile {
	local PMORCEAU
	local PABCFILE
	local NMORCEAU
	PMORCEAU=${MORCEAU}
	PABCFILE=${ABCFILE}
	echo "Morceau actuel : ${MORCEAU}"
	echo -n "Nouveau morceau : "
	read NMORCEAU
	MORCEAU=${NMORCEAU:-${MORCEAU}}
	MORCEAU=`basename $MORCEAU .abc`
	ABCFILE=${MORCEAU}.abc
	if [ ! -f ${ABCFILE} ]
	then
		MORCEAU=${PMORCEAU}
		ABCFILE=${PABCFILE}
	else
		ChInit
	fi
}

function Liste {
	local CRIT
	echo ""
	echo -n "Critère de sélection des fichiers : "
	read CRIT
	if [ ! "$CRIT" ]
	then
		CRIT="*.abc"
	fi
	ls -dF $CRIT
}

function Chdir {
	local NREP
	echo "Le Répertoire actuel est : `pwd`"
	echo -n "Nouveau Répertoire : "
	read NREP
	if [ -d "$NREP" ]
	then
		cd $NREP
		PWD=`pwd`
		ChInit
	else
		echo "\"$NREP\" n'est pas un répertoire valide"
	fi
}

function MakeMakefile {
	echo "" > Makefile
	echo "" >> Makefile
	echo "$MIDIFILE: $ABCFILE" >> Makefile
	echo "	abc2midi $ABCFILE" >> Makefile
	echo "" >> Makefile
	echo "$PSFILE: $ABCFILE" >> Makefile
	if [ -f ${FMTFILE}.fmt ]
	then
		echo "	abc2ps ${ABCFILE} -F $FMTFILE -O ${MORCEAU}.ps" >> Makefile
	else
		echo "	abc2ps ${ABCFILE} -O ${MORCEAU}.ps" >> Makefile
	fi
	echo "" >> Makefile
}

function Mkmidi {
	if [ $FORCE = "yes" ]
	then
		rm -f $MIDIFILE
	fi
	MakeMakefile
	make $MIDIFILE
}

function Mkps {
	if [ $FORCE = "yes" ]
	then
		rm -f $PSFILE $EPSFILE
	fi
	MakeMakefile
	make $PSFILE
}

function  Viewps {
	if [ -f $PSFILE ]
	then
		# gv --scale=-1 $PSFILE &
		OpenPS.sh $PSFILE &
	else
		MakeMakefile
		make $PSFILE
		OpenPS.sh $PSFILE &
	fi
}

function Editer {
	$ABCEDITOR $ABCFILE
	echo $!
}

function Jouer_old {
	local STTY
	MIDIFILE=${MORCEAU}1.mid
	# echo "AMPLI = $AMPLI"
	# if [ ! -f ${MIDIFILE} ]
	# then
	MakeMakefile
	make ${MIDIFILE}
	# fi
	# STTY=`stty --save`
	# timidity -is -A $AMPLI -P$PATCH $MIDIFILE # > /dev/null
	# timidity -is -P $PATCH -A $AMPLI $MIDIFILE
	# timidity -is -A $AMPLI -EFchorus=2,50 -EFreverb=2 -P ${PATCH} $MIDIFILE
	# timidity -is -A $AMPLI -EFchorus=2,50 -EFreverb=2  $MIDIFILE
	timidity -A $AMPLI -EFchorus=2,50 -EFreverb=2  $MIDIFILE
	# stty $STTY
}

function Jouer_old2 {
osascript -e "set theMidiFile to \"file:///$PWD/$MIDIFILE\"" -e '
on playMidi (theMidiFile)
tell application "Safari"
set MidiURL to theMidiFile
set nbMIDI to (count of (every document whose URL is MidiURL))
set nb to (count of (every document whose name is "MIDI"))
if (nbMIDI = 0) then
	set MIDI to make new document with properties {URL:MidiURL}
	tell front window
		set bounds to {0, 0, 400, 200}
	end tell
else
	close front window
	set MIDI to make new document with properties {URL:MidiURL}
	tell front window
		set bounds to {0, 0, 400, 200}
	end tell
end if
end tell
end playMidi' -e 'playMidi (theMidiFile)'
}	

function Jouer {
echo "${ABCFILE} ${MIDIFILE} ${PSFILE} $PWD"
rm -f ABCHTML.html
VITESSE=`grep '^Q:' ${ABCFILE} | awk '{print $2}' FS=":"`
PARTIES=`grep '^P:' ${ABCFILE} | head -1 | awk '{print $2}' FS=":"`
rm -f ABCIMG.jpeg
[ -f ${MORCEAU}001.eps ] && mv ${MORCEAU}001.eps ${PSFILE}
convert ${PSFILE} -filter Catrom  -resize 600 ABCIMG.png
# convert  ${PSFILE} jpg:- | convert jpg:- -resize 500 jpg:ABCIMG.jpeg
# convert  ${PSFILE} png:- | convert png:- -resize 500 png:ABCIMG.png
echo "
<html>
<head>  
<meta name="pragma" CONTENT="no-cache"> 
<title>
     ${ABCFILE}
</title>

</head>
<body>
<h1>${ABCFILE}</h1>
Vitesse = ${VITESSE}<br />
Parties = ${PARTIES}<br />
<object>
<embed height=\"30\" autostart=true src=\"file://$PWD/$MIDIFILE\">
</embed>
</object>
<br />
<img src=\"$PWD/ABCIMG.png\">
<pre>
`cat ${ABCFILE}`
</pre>
<br />
<!--
<img width=\"692\"src=\"$PWD/ABCIMG.jpeg\">
-->
<br />
</body></html>
" > ABCHTML.html
open -a /Applications/Safari.app ABCHTML.html
# open -a /Applications/Firefox.app ABCHTML.html
}

function Vitesse {
	local Q
	local VITE
	local XVITE
	Q=`grep ^Q: ${ABCFILE}`
	if [ ! "$Q" ]
	then
		echo "La marque Q: n'est pas présente dans le fichier"
		echo "             Il faut éditer le fichier abc"
		return
	fi
	VITE=`echo $Q | cut -d: -f2`
	echo -n "Nouvelle vitesse [$VITE] : "
	read XVITE
	if [ "$XVITE" -a "$XVITE" != $VITE ]
	then
		echo "sed en route $XVITE"
		PATT="s/^Q:[0-9/=]*/Q:$XVITE/"
		sed -i k -e $PATT $ABCFILE
	fi

	PARTIES=`grep '^P:' ${ABCFILE} | head -1 | awk '{print $2}' FS=":"`
	echo -n "Nouvelles parties [$PARTIES] : "
	read XPARTIES
	LENXPARTIES=`echo $XPARTIES | awk '{print length($1)}'`
	if [ "$XPARTIES" -a ${LENXPARTIES} -gt 1 -a "$XPARTIES" != $PARTIES ]
	then
		echo "sed en route $XPARTIES"
		PATT="s/^P:$PARTIES/P:$XPARTIES/"
		sed -i k -e $PATT $ABCFILE
	fi

#		ed -s $ABCFILE << FINVITE > /dev/null
#/Q:
#s/.//g
#s/$/Q:${XVITE}/
#wq
#FINVITE
	make $MIDIFILE
}

function force {
	if [ $FORCE = "yes" ]
	then
		FORCE="no"
	else
		FORCE="yes"
	fi
}

function Unlock {
	rm -f $LOCK
}

function grouper_Tout {
	echo "=========="
	echo $PWD
	local I
	local FICH
	PREC_PWD=$PWD
	HTML="index.html"
	XMORCEAU=$MORCEAU
	XMIDIFILE=$MIDIFILE
	XABCFILE=$ABCFILE
	XPSFILE=$PSFILE
	TITRE=`basename $PWD`
	N=1
	# REPGROUPREP="${SERIES}/.${TITRE}"
	REPGROUPREP="${PWD}/00-${TITRE}-ALL"
	if [ ! -d ${REPGROUPREP} ]
	then
		mkdir ${REPGROUPREP}
	fi
	cd ${REPGROUPREP}
	echo ${REPGROUPREP}
	echo ${PREC_PWD}
	echo "=========="
	rm -f ${HTML}
	echo "<html> <head>  <meta name="pragma" CONTENT="no-cache"> <title> ${TITRE} </title> </head> <body>" > ${HTML}
	echo "<center><h1>${TITRE}</h1></center>" >> ${HTML}
	if [ -d ${REPGROUPREP} ]
	then
		for FICH in `ls ${PREC_PWD}/*.abc`
		do
			echo $FICH
			cp $FICH .
			MORCEAU=`basename $FICH .abc`
			MIDIFILE=${MORCEAU}1.mid
			PSFILE=${MORCEAU}.ps
			ABCFILE=${MORCEAU}.abc
			VITESSE=`grep '^Q:' ${ABCFILE} | awk '{print $2}' FS=":"`
			PARTIES=`grep '^P:' ${ABCFILE} | head -1 | awk '{print $2}' FS=":"`
			IMG=${MORCEAU}.png
			MakeMakefile
			FORCE="yes"
			Mkmidi
			Mkps
			[ -f ${MORCEAU}001.eps ] && mv ${MORCEAU}001.eps ${PSFILE}
			# convert ${PSFILE} ${JPEG}
			# convert  ${PSFILE} jpg:- | convert jpg:- -resize 700 jpg:${JPEG}
			convert ${PSFILE} -filter Catrom  -resize 630 ${IMG}
			echo "
			<h2>${ABCFILE}</h2>
			Vitesse = ${VITESSE}<br />
			Parties = ${PARTIES}<br />
			<object>
			<embed height=\"30\" autostart=false src=\"file://$PWD/$MIDIFILE\">
			</embed>
			</object>
			<br />
			<img src=\"$IMG\">" >> index.html
		done
		open -a /Applications/Safari.app  $OUT_PS
	fi
	echo "</body> </html>" >> index.html
	open -a /Applications/Safari.app index.html
	PWD=$PREC_PWD
	MORCEAU=$XMORCEAU
	MIDIFILE=$XMIDIFILE
	ABCFILE=$XABCFILE
	PSFILE=$XPSFILE
	cd $PWD
	pwd
	# . $INIT
	# Usage
}

if [ -f ${LOCK} ]
then
	echo -e "Un autre ${_J}shabc${_N} est actuellement actif."
	echo -e "Sortie de ce programme tant que \"${_R}${LOCK}${_N}\" existe."
	# sleep 3
	exit
fi

trap Unlock EXIT
touch $LOCK
Usage

while [ 1 ]
do
	HEURE=`date '+%H:%M:%S'`
	rouge "$HEURE "
	echo -n "Action : "
	T=`readc`
	case $T in
	a) echo "Autre morceau"
		Chfile
		MakeMakefile
		Mkmidi
		Mkps
		;;
	c) echo "Charger une nouvelle série"
		serie_charger
		;;
	d) echo "Changement des paramètres par défaut"
		parametres
		;;
	e|é) echo "Editer le fichier $ABCFILE"
		Editer
		;;
	f) echo "force..."
	        force 
	        ;;
	h) echo "historique"
		Hist
		;;
	H) echo "Mise à jour de l'historique"
		MajHist
		;;
	I) echo "insérer le morcreau actuel dans la série"
		serie_inserer
		;;
	i) echo "Contruction du fichier Midi"
		Mkmidi
		;;
	j|0) echo "Jouer le morceau $MORCEAU"
		Jouer
		;;
	J|9) echo "Jouer les morceau de la série ${SERIE} dans un ordre aléatoire"
		serie_jouer_aleatoire
		;;
	L) echo "Lister les fichiers"
		Liste
		;;
	l) echo "lister la série et choisir un morceau"
		serie_lister
		;;
	M) echo "Contruction du Makefile"
		MakeMakefile
		echo " done."
		;;
	N) echo "Créer une nouvelle série"
		serie_nouvelle
		;;
	P|1) echo "voir la Partition"
		Viewps
		;;
	p) echo "Contruction du fichier Postscript"
		Mkps
		;;
	q|Q) echo "Sortie ..."
		rm -f $LOCK
		ChInit2
		exit
		;;
	r) echo "Changement de Répertoire"
		Chdir
		;;
	s) echo "gestion des séries"
		series
		;;
	t) echo "transposition"
		transpose
		;;
	v) echo "Changement de vitesse de jeu du morceau"
		Vitesse
		;;
	g) echo "regrouper les morceaux de la série dans une même partition"
		serie_grouper
		;;
	G) echo "regrouper les morceaux de la série dans une même partition"
		serie_grouper2
		;;
	T) echo "regrouper Tous les morceaux du répertoire"
		grouper_Tout
		;;
	'?') Autres_commandes
		;;
	*) Usage
		;;
	esac

done

