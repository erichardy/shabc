# Initialisation des couleurs
function rouge {
	echo -en "\033[31;40;1m${@}\033[37;40;0m"
}


function jaune {
	echo -en "\033[33;40;1m${@}\033[37;40;0m"
}


function magenta {
	echo -en "\033[36;40;1m${@}\033[37;40;0m"
}

function vert {
	echo -en "\033[32;40;1m${@}\033[37;40;0m"
}

function inverse {
	echo -en "\033[30;47m${@}\033[37;40;0m"
}

ROUGE="\033[31;40;1m"
JAUNE="\033[33;40;1m"
VERT="\033[32;40;1m"
MAGENTA="\033[36;40;1m"
NORM="\033[37;40;0m"
GRAS="\033[37;40;1m"

_R=$ROUGE
_J=$JAUNE
_V=$VERT
_M=$MAGENTA
_N=$NORM
_G=$GRAS
