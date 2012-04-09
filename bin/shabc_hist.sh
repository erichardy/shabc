#!/bin/sh

# shabc VERSION 0.1
# fichier des fonction de gestion de l'historique général

function EchoHist {
	local I
	local NOM
	local NOMABC
	local REPABC
	
	I=1
	for NOM in `echo "${M[@]}"`
	do
		NOMABC=`basename $NOM`
		REPABC=`dirname $NOM`
		echo -e "$I : ${_V}$NOMABC${_N} (${REPABC})"
		I=`expr $I + 1`
	done
	I=`expr $I - 1`
	NB_HIST=$I

}

function Hist {
	local NUM
	local NOUVEAU
	echo "le répertoire courant est : $PWD"
	echo "Le fichier courrant est : $MORCEAU.abc"
	EchoHist
	echo -n "Choix du morceau (Numero ?) : "
	read NUM
	if [ ! "$NUM" ]
	then
		return
	fi
	expr ${NUM} + 1 2> /dev/null || NUM=1
	if [ "$NUM" -gt ${NB_HIST} ]
	then
		NUM=${NB_HIST}
	fi
	if [ "$NUM" -lt 1 ]
	then
		NUM=1
	fi
	NOUVEAU=${M[${NUM}]}
	if [ ! -f $NOUVEAU ]
	then
		echo "ATTENTION : $NOUVEAU n'existe pas !!!!"
		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	else
		# echo "::::: $NOUVEAU"
		ABCFILE=`basename $NOUVEAU`
		MORCEAU=`basename $NOUVEAU .abc`
		PWD=`dirname $NOUVEAU`
		# echo "Dans Hist : $ABCFILE $MORCEAU $NOUVEAU $PWD"
	# exit
		cd $PWD
		ChInit
		MakeMakefile
	fi
}

function MajHist {
	local NUM
	EchoHist
	echo -n "Morceau courrant à insérer au Numéro ? : "
	read NUM
	# expr ${NUM} + 1 2> /dev/null || (echo "$NUM non valide" ; sleep 2 ; return)
	expr ${NUM} + 1 2> /dev/null ||  return
	if [ ! "$NUM" ]
	then
		return
	fi
	if [ "${NUM}" -gt "${NB_HIST}" ]
	then
		NUM=`expr $NB_HIST + 1`
		NB_HIST=`expr ${NB_HIST} + 1`
	fi
	FICHIER=$PWD/$ABCFILE
	M[${NUM}]=$FICHIER
	ChInit
}
