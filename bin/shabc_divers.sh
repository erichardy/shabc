#!/bin/sh

function readc {
	oldstty=`stty -g`
	stty -icanon -echo min 1 time 0
	dd bs=1 count=1 <&0 2>/dev/null
	stty $oldstty
}

function Usage_param {
	clear
	jaune "=============================================================" ; echo
	echo -e "Changement des paramètres par défaut"
	echo -e "1 : Editeur (${_V}$ABCEDITOR${_N})"
	echo -e "2 : AMPLI (${_V}$AMPLI${_N})"
	echo -e "3 : Nombre Max de morceaux dans l'historique (${_V}$MAX_HIST${_N})"
	echo -e "4 : purge des fichier Midi et Postcript dans ${_V}$PWD${_N}"
	echo -e "0 : Retour au programme principal"
	jaune "=============================================================" ; echo
	echo -n "Choix : "
}

function parametres {
	local CHOIX
	while [ 1 ]
	do
	Usage_param
	CHOIX=`readc`
		case $CHOIX in
			1) ChEditor
				;;
			2) ChAmpli
				;;
			3) ChMaxhist
				;;
			4) Purge
				;;
			0|q) Usage ; return
				;;
			*) ;;
		esac
	done
}

function ChMaxhist {
	local XMAXH
	echo -e "Nombre Maxi de morceaux dans l'historique : ${_V}${MAX_HIST}${_N}"
	echo -n "Nouvelle valeur : "
	read XMAXH
	expr "${XMAXH}" + 0 2> /dev/null || return
	MAX_HIST=${XMAXH}
	ChInit2
}

function ChAmpli {
	local XAMPLI
	echo -e "Valeur actuelle de AMPLI : ${_V}${AMPLI}${_N}"
	echo -n "Nouvelle valeur (entre 0 et 800) : "
	read XAMPLI
	expr "${XAMPLI}" + 0 2> /dev/null || XAMPLI=${AMPLI}
	if [ "${XAMPLI}" -lt 0 -o "${XAMPLI}" -gt 800 ]
	then
		echo "Valeur donnée : ${_R}${XAMPLI}${_N} non valide !"
		# sleep 2
	else
		AMPLI=${XAMPLI}
		ChInit2
	fi
}

function Purge {
	local CHOIX
	echo -e "Supprimer tous les fichiers ${_R}midi${_N} et ${_R}PostScript${_N}"
	echo -en "dans le répertoire ${_V}$PWD${_N} (O/N) ? "
	CHOIX=`readc`
	echo $CHOIX
	if [ "${CHOIX}" = 'o' -o "${CHOIX}" = 'O' ]
	then
		cd $PWD
		rm -f *.mid *.ps
		rouge "Suppression effectuée." ; echo
		# sleep 1
	fi
}

function ChEditor {
	local EXISTE
	local COMM
	local  EDIT
	local REPONSE
	echo -e "Editeur actuel : ${_V}${ABCEDITOR}${_N}"
	echo -n "Nouvel éditeur : "
	read EDIT
	EDITEUR=${EDIT:-$ABCEDITOR}
	echo -ne "Tester ${_J}$EDITEUR${_N} (O/N) : "
	read REPONSE
	case ${REPONSE} in
		o|O|y|Y) COMM=`echo $EDIT | awk '{print $1}'`
					EXISTE=`which "$COMM"`
					if [ -x "$EXISTE" ]
					then
						$EDIT
						echo -n "Cela convient il (o/n) ? "
						read REPONSE
						if [ "$REPONSE" = 'o' -o "$REPONSE" = 'O' ]
						then
							ABCEDITOR=$EDIT
							ChInit2
						fi
					else
						echo -e "${_R}${EDIT}${_N} n'existe pas !"
						# sleep 2
					fi
			;;
		*) ABCEDITOR=${EDITEUR}
			;;
	esac
}

function transpose {
	local DEMITONS
	local FICHIER=${PWD}/${ABCFILE}
	local NFICHIER
	local XFICHIER
	echo -ne "Nombre de demi-tons (${_V}-n${_N} ou ${_V}n${_N}) : "
	read DEMITONS
	expr ${DEMITONS} + 1 2>1 > /dev/null || return
	NFICHIER=`basename ${ABCFILE} .abc`
	NFICHIER="${PWD}/${NFICHIER}_${DEMITONS}_.abc"
	echo "nom du nouveau fichier : [${NFICHIER}]"
	read XFICHIER
	XFICHIER=${XFICHIER:=${NFICHIER}}
	# echo "$XFICHIER"
	NREP=`dirname ${XFICHIER}`
	if [ ! -d ${RNREP} ]
	then
		echo "Le répertoire ${NREP} n'est pas accessible, sortie"
		return
	fi
	abc2abc ${FICHIER} -t ${DEMITONS} > ${XFICHIER}
}
