#!/bin/sh

# (@) shabc_init.sh
# Création des éléments d'initialisation pour le programme shabc

# La variable SHABC_VERSION est donnée par l'exécutable principal : shabc

# echo "shabc : Version ${SHABC_VERSION} / $1"

ACTION=$1

if [ "$ACTION" = "Init" ]
then
	touch $INIT
	chmod 644 $INIT
	DATE=`date '+%a %d/%m/%Y %H h %M m %S s'`
	echo "# Fichier d'initialisation de $USER créé le $DATE" >> $INIT
	echo "SHABC_VERSION=${SHABC_VERSION}" >> $INIT
	echo "LOCK=${HOME}/.shabc.lock" >> $INIT
	# Date de dernière modification
	echo "MODIF='$DATE'" >> $INIT
	# nom de l'éditeur de fichiers abc
	echo "ABCEDITOR=${EDITOR:='gvim -rv '}" >> $INIT
	# Valeur de AMPLI : volume de timidity
	echo "AMPLI=400" >> $INIT
	# Dernier répertoire courrant
	echo "PWD=${HOME}" >> $INIT
	# nom du dernier morceau édité dans le répertoire donné dans $PWD
	echo "MORCEAU=premier" >> $INIT
	# Taille de la liste de l'historique principal
	echo "NB_HIST=1" >> $INIT
	# Taille Maximale de l'historique
	echo "MAX_HIST=20" >> $INIT
	# Nom du répertoire des séries
	echo "SERIES=${SERIES}" >> $INIT
	# Nom de la dernière série utilisée
	echo "SERIE=" >> $INIT
	# initialisation d'un premier morceau dans l'historique
	echo "M[1]=/home/eric/premier.abc" >> $INIT
fi

if [ "$ACTION" = "Rep_series" ]
then
	mkdir ${SERIES}
fi


if [ "$ACTION" = "Refaire" ]
then
	rm -f  $INIT
	touch  $INIT
	chmod 644 $INIT
	DATE=`date '+%a %d/%m/%Y %H h %M m %S s'`
	echo "# Fichier d'initialisation de $USER modifié le $DATE" >> $INIT
	echo "SHABC_VERSION=${SHABC_VERSION}" >> $INIT
	echo "LOCK=$LOCK" >> $INIT
	# Date de dernière modification
	echo "MODIF='$DATE'" >> $INIT
	# nom de l'éditeur de fichiers abc
	# echo "ABCEDITOR=${ABCEDITOR:='gvim -rv -fn lucidasanstypewriter-10'}" >> $INIT
	echo "ABCEDITOR='${ABCEDITOR}'" >> $INIT
	# Valeur de AMPLI : volume de timidity
	echo "AMPLI=${AMPLI}" >> $INIT
	# Dernier répertoire courrant
	echo "PWD=${PWD}" >> $INIT
	# nom du dernier morceau édité dans le répertoire donné dans $PWD
	echo "MORCEAU=${MORCEAU}" >> $INIT
	# Nom du répertoire des séries
	echo "SERIES=${SERIES}" >> $INIT
	# Nom de la dernière série utilisée
	echo "SERIE=$SERIE" >> $INIT
	# Taille Maximale de l'historique
	echo "MAX_HIST=${MAX_HIST}" >> $INIT
	# initialisation d'un premier morceau dans l'historique
	# echo "M[1]=premier" >> $INIT
	# Reste à include la liste des morceaux de l'historique général
	I=1
	for NOM in `echo ${M[*]}`
	do
		echo "M[${I}]=${M[$I]}" >> $INIT
		I=`expr $I + 1`
	done
	# Taille de la liste de l'historique principal
	NB_HIST=`expr $I - 1`
	echo "NB_HIST=$NB_HIST" >> $INIT
	serie_courante
fi
