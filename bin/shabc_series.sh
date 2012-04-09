#!/bin/sh

function serie_grouper2 {
	local I
	local FICH
	PREC_PWD=$PWD
	XMORCEAU=$MORCEAU
	XMIDIFILE=$MIDIFILE
	XABCFILE=$ABCFILE
	XPSFILE=$PSFILE
	N=1
	LASERIE=${SERIES}/${SERIE}
	REPGROUPSERIE="${SERIES}/.${SERIE}"
	if [ ! -d ${REPGROUPSERIE} ]
	then
		mkdir ${REPGROUPSERIE}
	fi
	cd ${REPGROUPSERIE}
	rm -f HTML.html
	echo "<html> <head>  <meta name="pragma" CONTENT="no-cache"> <title> ${SERIE} </title> </head> <body>" > HTML.html
	echo "<center><h1>${SERIE}</h1></center>" >> HTML.html
	# echo "la série : ${LASERIE} ${SERIE} ${SERIES}"
	# echo "${REPGROUPSERIE}"
	if [ -f ${LASERIE} ]
	then
		for FICH in `cat ${LASERIE}`
		do
			echo $FICH
			cp $FICH .
			MORCEAU=`basename $FICH .abc`
			MIDIFILE=${MORCEAU}1.mid
			PSFILE=${MORCEAU}.ps
			ABCFILE=${MORCEAU}.abc
			VITESSE=`grep '^Q:' ${ABCFILE} | awk '{print $2}' FS=":"`
			PARTIES=`grep '^P:' ${ABCFILE} | head -1 | awk '{print $2}' FS=":"`
			JPEG=${MORCEAU}.jpg
			MakeMakefile
			FORCE="yes"
			Mkmidi
			Mkps
			[ -f ${MORCEAU}001.eps ] && mv ${MORCEAU}001.eps ${PSFILE}
			convert ${PSFILE} ${JPEG}
			echo "
			<h2>${ABCFILE}</h2>
			Vitesse = ${VITESSE}<br />
			Parties = ${PARTIES}<br />
			<object>
			<embed height=\"30\" autostart=false src=\"file://$PWD/$MIDIFILE\">
			</embed>
			</object>
			<br />
			<img src=\"$PWD/$JPEG\">" >> HTML.html
		done
		open -a /Applications/Safari.app  $OUT_PS
	fi
	echo "</body> </html>" >> HTML.html
	open -a /Applications/Safari.app HTML.html
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

function serie_grouper {
	local I
	local FICH
	N=1
	LASERIE=${SERIES}/${SERIE}
	REPGROUPSERIE="${SERIES}/.${SERIE}"
	OUT_ABC=${REPGROUPSERIE}/all.abc
	OUT_PS=${REPGROUPSERIE}/all.ps
	rm -f ${OUT_ABC}
	echo '%%footer $D       $P' > $OUT_ABC
	echo '%%topmargin 2cm' >> $OUT_ABC
	if [ ! -d ${REPGROUPSERIE} ]
	then
		mkdir ${REPGROUPSERIE}
	fi
	# echo "la série : ${LASERIE} ${SERIE} ${SERIES}"
	# echo "${REPGROUPSERIE}"
	if [ -f ${LASERIE} ]
	then
		I=0
		for FICH in `cat ${LASERIE}`
		do
			echo $FICH
			echo "X:$N" >> $OUT_ABC
			grep -v 'X:' $FICH | grep -v 'Q:' | grep -v 'P:'  >> $OUT_ABC
			N=`expr $N + 1`
			echo "" >> $OUT_ABC
			I=$(( $I + 1))
		done
		abc2ps $OUT_ABC -P -I -x -o -O $OUT_PS
		open -a /Applications/Safari.app  $OUT_PS
	fi
}

function serie_courante {
	local I
	local FICH
	TSERIE=()
	LASERIE=${SERIES}/${SERIE}
	if [ -f ${LASERIE} ]
	then
		local I
		local FICH
		I=0
		for FICH in `cat ${LASERIE}`
		do
			# echo $FICH
			TSERIE[$I]=$FICH
			I=$(( $I + 1))
		done
		TAILLESERIE=`Tab_taille ${TSERIE[*]}`
		# sleep 5
	fi
}

function serie_maj {
	LASERIE=${SERIES}/${SERIE}
	rm -f ${LASERIE}
	local I=0
	while [ ${TSERIE[$I]} ]
	do
		echo "${TSERIE[$I]}" >> ${LASERIE}
		I=$(( $I + 1 ))
	done
}

function serie_charger {
	# echo "$SERIES"
	local -a REPSERIES
	local I=0
	local NUM
	local ERREUR
	REPSERIES=(`(cd $SERIES ; ls)`)
	while [ ${REPSERIES[$I]} ]
	do	
		echo "$I : ${REPSERIES[$I]}"
		I=$(($I + 1))
	done	
	I=$(( I - 1 ))
	echo -n "Numéro : "
	read NUM
	ERREUR=`expr ${NUM} + 1 2> /dev/null` || return
	if [ ${NUM} -lt 0 -o ${NUM} -gt $I ]
	then
		rouge "Numéro non valide : $NUM" ; echo
		return
	fi
	SERIE=${REPSERIES[$NUM]}
	serie_courante
	ChInit2
	Usage
}

function serie_nouvelle {
	local NSERIE
	local XSERIE
	echo "séries existantes :"
	(cd $SERIES ; ls)
	echo -n "Nom de la série : "
	read XSERIE
	NSERIE=${XSERIE:-${SERIE}}
	if [ -f ${SERIES}/${NSERIE} ]
	then
		echo "La série <${NSERIE}> existe déjà : pas de changement"
		return
	fi
	SERIE=${NSERIE}
	touch ${SERIES}/${SERIE}
	serie_courante
	ChInit2
	Usage
}

function serie_inserer {
	local NUM
	local FICHIER
	serie_liste
	echo -n "Numéro où insérer le morceau : "
	read NUM
	expr ${NUM} + 2 2>&1 > /dev/null || return
	FICHIER=${PWD}/${ABCFILE}
	# echo "Fichier = $FICHIER $TAILLESERIE $SERIE $SERIES"
	if [ ${TAILLESERIE} -eq 0 ]
	then
		# echo "taill = 0"
		TSERIE=(${FICHIER})
		serie_liste
	else
		TSERIE=(`Tab_inserer ${FICHIER} $NUM ${TSERIE[@]}`)
	fi
	serie_maj
	serie_courante
}

function serie_liste {
	local I=0
	local FICH
	local REP
	while [ "${TSERIE[$I]}" ]
	do
		FICH=`basename ${TSERIE[$I]}`
		REP=`dirname ${TSERIE[$I]}`
		echo -e "$I : ${_V}${FICH}${_N} (${REP})"
		I=$(( $I + 1 ))
	done
}

function serie_lister {
	serie_liste
	local NUM
	local FICHIER
	echo -n "Numéro : "
	read NUM
	# expr ${NUM} + 1 2>&1 > /dev/null || return
	expr ${NUM} + 1 > /dev/null 2>&1 || return
	# sleep 2
	if [ ${NUM} -lt 0 ]
	then
		NUM=0
	fi
	if [ ${NUM} -gt ${TAILLESERIE} ]
	then
		NUM=$(( ${TAILLESERIE} - 1 ))
	fi
	FICHIER=${TSERIE[${NUM}]}
	PWD=`dirname ${FICHIER}`
	MORCEAU=`basename ${FICHIER} .abc`
	ABCFILE=`basename ${FICHIER}`
	ChInit2
	MakeMakefile
	Usage
}

function serie_debut {
	serie_liste
	local NUM
	local FICHIER
	echo -n "Numéro : "
	read NUM
	expr ${NUM} + 1 > /dev/null 2>&1 || return
	if [ ${NUM} -eq 0 ]
	then
		return
	fi
	if [ ${NUM} -lt 0 ]
	then
		rouge "${NUM} Non valide !"
		# sleep 2
		return
	fi
	if [ ${NUM} -ge ${TAILLESERIE} ]
	then
		rouge "${NUM} Non valide !"
		# sleep 2
		return
	fi
	FICHIER=${TSERIE[${NUM}]}
	TSERIE=(`Tab_retirer $NUM ${TSERIE[@]}`)
	TSERIE=(`Tab_inserer ${FICHIER} 0 ${TSERIE[@]}`)
	serie_maj
	serie_courante
}

function serie_fin {
	serie_liste

	local NUM
	local T
	local FICHIER
	echo -n "Numéro : "
	read NUM
	expr ${NUM} + 1 > /dev/null 2>&1 || return
	T=$(( ${TAILLESERIE} - 1 ))
	if [ ${NUM} -eq $T ]
	then
		return
	fi
	if [ ${NUM} -lt 0 ]
	then
		rouge "${NUM} Non valide !"
		# sleep 2
		return
	fi
	if [ ${NUM} -ge ${TAILLESERIE} ]
	then
		rouge "${NUM} Non valide !"
		# sleep 2
		return
	fi
	FICHIER=${TSERIE[${NUM}]}
	TSERIE=(`Tab_retirer $NUM ${TSERIE[@]}`)
	TSERIE=(`Tab_ajout ${FICHIER} ${TSERIE[@]}`)
	
	serie_maj
	serie_courante
}

function serie_inverser {
	local ERR1
	local ERR2
	local M1
	local M2
	serie_liste
	echo -n "Premier morceau : "
	read M1
	expr "$M1" + 1 > /dev/null 2>&1
	ERR1=$?
	[ $ERR1 -eq 0 ] || return

	echo -n "second morceau  : "
	read M2
	expr "$M2" + 1 > /dev/null 2>&1
	ERR2=$?
	[ $ERR2 -eq 0 ] || return

	if [ "$M1" -lt 0 ]
	then
		M1=0
	fi
	if [ "$M1" -ge ${TAILLESERIE} ]
	then
		M1=$(( ${TAILLESERIE} - 1 ))
	fi

	if [ "$M2" -lt 0 ]
	then
		M2=0
	fi
	if [ "$M2" -ge ${TAILLESERIE} ]
	then
		M2=$(( ${TAILLESERIE} - 1 ))
	fi
	echo "$M1 $M2"
	# sleep 3
	if [ "$M1" -eq "$M2" ]
	then
		return
	fi
	TSERIE=(`Tab_echange $M1 $M2 ${TSERIE[@]}`)
	serie_maj
	serie_courante
}

function serie_supprimer {
	serie_liste
	local NUM
	local FICHIER
	echo -n "Numéro : "
	read NUM
	expr ${NUM} + 1 > /dev/null 2>&1 || return
	if [ ${NUM} -lt 0 ]
	then
		rouge "Non valide !"
		# sleep 2
		return
	fi
	if [ ${NUM} -ge ${TAILLESERIE} ]
	then
		rouge "Non valide !"
		# sleep 2
		return
	fi
	FICHIER=${TSERIE[${NUM}]}
	TSERIE=(`Tab_retirer $NUM ${TSERIE[@]}`)
	serie_maj
	serie_courante
}

function serie_jouer {
	local I=0
	local T=$(( ${TAILLESERIE} - 1 ))
	local XPWD=$PWD
	local XMORCEAU=$MORCEAU
	local XABCFILE=$ABCFILE
	local LISTE_MIDIFILES=""
	while [ $I -le $T ]
	do
		FICHIER=${TSERIE[$I]}
		PWD=`dirname ${FICHIER}`
		MORCEAU=`basename ${FICHIER} .abc`
		ABCFILE=`basename ${FICHIER}`
		MIDIFILE=${MORCEAU}1.mid
		cd $PWD
		MakeMakefile
		Mkmidi
		I=$(( $I + 1 ))
	done
	I=0
	while [ $I -le $T ]
	do
		FICHIER=${TSERIE[$I]}
		PWD=`dirname ${FICHIER}`
		MORCEAU=`basename ${FICHIER} .abc`
		ABCFILE=`basename ${FICHIER}`
		MIDIFILE=${MORCEAU}1.mid
		LISTE_MIDIFILES="${LISTE_MIDIFILES} $PWD/${MIDIFILE}"
		# cd $PWD
		# Jouer
		I=$(( $I + 1 ))
	done
	timidity -is -A $AMPLI -P${PATCH} ${TIMIDITY_EFFECTS} ${LISTE_MIDIFILES}
	PWD=$XPWD
	MORCEAU=$XMORCEAU
	ABCFILE=$XABCFILE
	cd $PWD
}

function serie_jouer_aleatoire {
	local I=0
	local T=$(( ${TAILLESERIE} - 1 ))
	local XPWD=$PWD
	local XMORCEAU=$MORCEAU
	local XABCFILE=$ABCFILE
	local LISTE_MIDIFILES=""
	while [ $I -le $T ]
	do
		FICHIER=${TSERIE[$I]}
		PWD=`dirname ${FICHIER}`
		MORCEAU=`basename ${FICHIER} .abc`
		ABCFILE=`basename ${FICHIER}`
		MIDIFILE=${MORCEAU}1.mid
		cd $PWD
		MakeMakefile
		Mkmidi
		I=$(( $I + 1 ))
	done
	I=0
	TAB_ALEATOIRE=(`(shabc_rand -ul ${TAILLESERIE})`)

	while [ $I -le $T ]
	do
		INDICE_ALEATOIRE=${TAB_ALEATOIRE[$I]}
		FICHIER=${TSERIE[${INDICE_ALEATOIRE}]}
		PWD=`dirname ${FICHIER}`
		MORCEAU=`basename ${FICHIER} .abc`
		ABCFILE=`basename ${FICHIER}`
		MIDIFILE=${MORCEAU}1.mid
		LISTE_MIDIFILES="${LISTE_MIDIFILES} $PWD/${MIDIFILE}"
		# cd $PWD
		# Jouer
		# echo ${FICHIER}
		I=$(( $I + 1 ))
	done
	# echo "liste des fichiers MIDI : ${LISTE_MIDIFILES}"
	timidity -is -A $AMPLI ${TIMIDITY_EFFECTS} ${LISTE_MIDIFILES}
	PWD=$XPWD
	MORCEAU=$XMORCEAU
	ABCFILE=$XABCFILE
	cd $PWD
}

function series {
	# supprimer un morceau de la série
	# inverser 2 morceaux de la série
	# mettre le morceau courant au début
	# mettre le morceau courant à la fin
	# supprimer une série
	while [ 1 ]
	do
		local S
		clear
		echo -e "   Série en cours : ${_V}${SERIE}${_N}"
		jaune "=============================================================" ; echo
		echo -e "      s : ${_M}s${_N}upprimer un morceau de la série"
		echo -e "      i : ${_M}i${_N}nverser 2 morceaux"
		echo -e "      d : mettre un morceau au ${_M}d${_N}ébut"
		echo -e "      f : mettre un morceau à la ${_M}f${_N}in"
		echo -e "    j|0 : ${_M}j${_N}ouer la série"
		echo -e "      q : ${_M}q${_N}uitter ce menu"
		jaune "=============================================================" ; echo
		echo -n "Action : "
		S=`readc`
		case $S in
			d) echo "Mettre un morceau au début de la série"
				serie_debut
			;;
			f) echo "Mettre un morceau à la fin de la série"
				serie_fin
			;;
			i) echo "inversion de 2 morceaux dans l'ordre de la série"
				serie_inverser
			;;
			j|0) echo "jouer la série"
				serie_jouer
				;;
			J|9) echo "jouer la série dans un ordre aléatoire"
				serie_jouer_aleatoire
				;;
			s) echo "suppression d'un morceau de la série"
				serie_supprimer
			;;
			q|Q) Usage
				return
			;;
			*) clear
			;;
		esac
	done
}
