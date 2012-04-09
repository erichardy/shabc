#!/bin/sh

function Tab_affiche {
	local -a TAB=($*)
	local I=0
	while [ "${TAB[$I]}" ]
	do
		echo "$I : ${TAB[$I]}"
		I=$(( $I + 1 ))
	done
}

function Tab_ajout {
	local AJOUT=$1
	shift
	local -a TAB=($*)
	local T
	T=`Tab_taille ${TAB[*]}`
	TAB[$T]="${AJOUT}"
	echo "${TAB[*]}"
	}

function Tab_retirer {
	# set -xv
	local RETIR=$1
	shift
	local -a TAB=($*)
	local T=`Tab_taille ${TAB[*]}`
	local I
	local II
	if [ $RETIR -ge $T ]
	then
		echo "${TAB[*]}"
		return
	fi
	I=${RETIR}
	II=$(( $I + 1))
	if [ $RETIR != $(( $T - 1 )) ]
	then
		while [ $I -lt $T ]
		do
			TAB[$I]=${TAB[$II]}
			I=$(( $I + 1))
			II=$(( $I + 1))
		done
		unset TAB[$(( $I - 1))]
	else
		unset TAB[$I]
	fi
	# unset ${TAB[$(( $I - 1))]}
	echo "${TAB[*]}"
}

function Tab_echange {
	local PARAM1=$1
	local PARAM2=$2
	shift
	shift
	local -a TAB=($*)
	local TEMP=${TAB[$PARAM1]}
	TAB[$PARAM1]=${TAB[$PARAM2]}
	TAB[$PARAM2]=$TEMP
	echo "${TAB[*]}"
}

function Tab_taille {
	local -a TAB=($*)
	local I
	local Elem
	I=0
	for Elem in "${TAB[@]}"
	do
		I=$(( $I + 1 ))
	done
	echo "$I"
}

function Tab_inserer {
	local OBJET=$1
	local INSER=$2
	shift
	shift
	local -a TAB=($*)
	local T=`Tab_taille ${TAB[*]}`
	local T1=$(( $T - 1 ))
	local TEMP
	if [ $INSER -ge $T ]
	then
		TAB=(`Tab_ajout $OBJET ${TAB[@]}`)
		echo "${TAB[*]}"
		return
	fi
	if [ $INSER = $T1 ]
	then
		TEMP=${TAB[$T1]}
		TAB[$T1]=$OBJET
		TAB[$T]=$TEMP
		echo "${TAB[*]}"
		return
	fi	
	local I=$INSER
	local II
	II=$T1
	TAB[$T]=${TAB[$T1]}
	while [ $II -gt $INSER ]
	do
		TAB[$II]=${TAB[$(( $II - 1 ))]}
		II=$(( $II - 1 ))
	done
	TAB[$II]=$OBJET
	echo "${TAB[*]}"
}

# utilisation des tableaux et des fonctions associées
# Les indices commencent à 0
#
# affectation des valeurs d'un tableau en dur : tableau=(a1i1 a2 a3 a4)
# declare -a tableau2=(L1 L22 L333 L4444 L55555 L6)
#
# afficher la taille du quatrième élément d'un tableau
# echo "${#tableau[3]}"
#
# utilisation de la fonction qui retourne le nombre d'éléments d'un tableau
# T=`Tab_taille ${tableau2[*]}`
# echo "Taille = $T"
#
# affichage à l'écran des éléments d'un tableau précédés de leur indice
# Tab_affiche ${tableau2[*]}
#
# échange de position de deux éléments d'un tableau dont les indices
# sont les 2 premiers paramètres
# tableau2=(`Tab_echange 1 2 ${tableau2[@]}`)
#
# retirer un élément du tableau, la taille de celui-ci est diminuée de 1
# tableau2=(`Tab_retirer 5 ${tableau2[@]}`)
#
# Ajouter en fin de tableau un élément qui est le premier paramètre
# tableau2=(`Tab_ajout L666666 ${tableau2[@]}`)
#
# insérer un élément ($1) à l'indice $2 dans un tableau
# tableau2=(`Tab_inserer AZE 3 ${tableau2[@]}`)
