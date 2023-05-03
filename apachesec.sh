#! /bin/bash
#----------------------------------INICIO SCRIPT----------------------------------#
echo ""
echo -e "   _____                      _               __    ___    __  _______ "
echo -e "  / ___/___  _______  _______(_)___  ___     / /   /   |  /  |/  / __ \ "
echo -e "  \__ \/ _ \/ ___/ / / / ___/ /_  / / _ \   / /   / /| | / /|_/ / /_/ / "
echo -e " ___/ /  __/ /__/ /_/ / /  / / / /_/  __/  / /___/ ___ |/ /  / / ____/  "
echo -e "/____/\___/\___/\__,_/_/  /_/ /___/\___/  /_____/_/  |_/_/  /_/_/    "    
echo ""
echo ""
#Variables.
fichapaReal="/etc/apache2/apache2.conf"
fichapaPrueba="sandbox/apache2.conf"
fichapa2Real="/etc/apache2/envvars"
fichapa2Prueba="sandbox/envvars"

fichapaReal=$fichapaPrueba
fichapa2Real=$fichapa2Prueba
#1. Usuario y grupo de ejecución.
echo -e "\e[1m1. Se va a revisar el parámetro de usuario de ejecución.\e[0m"
grep "^User.*\$.*" $fichapaReal
if [[ $? -eq 0 ]]
then
	echo "Se ha detectado una configuración dinámica con una variable de entorno en el parámetro"
	echo
	cadena=$(grep ^User.*$\.* ${fichapaReal})
	echo "Estado actual del parámetro: $cadena"
	cadena=${cadena#*\{}
	cadena=${cadena%\}*}
	grep "$cadena" $fichapa2Real
	#Este grep devolverá: export APACHE_RUN_USER=www-data
	cadena2=$(grep "$cadena" ${fichapa2Real})
	cadena2=${cadena2#*\=}
	
	if [[ $cadena2 != *"www-data"* ]]
	then
		echo "Le recomendamos que sustituya el usuario configurado actualmente por www-data."
	else
		echo "El usuario recomendado (www-data) coincide con el actual. ¡Buen trabajo!"
	fi
elif [[ $(grep "^User.*www-data" $fichapaReal) && $? -eq 0 ]]
then
	echo "Buen trabajo! El usuario configurado actualmente coincide con el recomendado (www-data)"
else
	echo "Le recomendamos que sustituya el usuario configurado actualmente por www-data."	
fi
echo
echo "Ahora vamos a comprobar el grupo de ejecución"
grep "^Group.*\$.*" $fichapaReal
if [[ $? -eq 0 ]]
then
	echo "Se ha detectado una configuración dinámica con una variable de entorno en el parámetro"
	cadena=$(grep ^Group.*$\.* ${fichapaReal})
	echo "Estado actual del parámetro: $cadena"
	cadena=${cadena#*\{}
	cadena=${cadena%\}*}
	grep "$cadena" $fichapa2Real
	#Este grep devolverá: export APACHE_RUN_GROUP=www-data
	cadena2=$(grep "$cadena" ${fichapa2Real})
	cadena2=${cadena2#*\=}
	
	if [[ $cadena2 != *"www-data"* ]]
	then
		echo "Le recomendamos que sustituya el usuario configurado actualmente por www-data."
	else
		echo "El usuario recomendado (www-data) coincide con el actual. ¡Buen trabajo!"
	fi
elif [[ $(grep "^Group.*www-data" $fichapaReal) && $? -eq 0 ]]
then
	echo "Buen trabajo! El usuario configurado actualmente coincide con el recomendado (www-data)"
else
	echo "Le recomendamos que sustituya el usuario configurado actualmente por www-data."	
fi
exit 0
