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
fichapa3Real="/etc/apache2/conf-available/security.conf"
fichapa3Prueba="sandbox/security.conf"

fichapaReal=$fichapaPrueba
fichapa2Real=$fichapa2Prueba
fichapa3Real=$fichapa3Prueba
#1. Usuario y grupo de ejecución.
echo -e "\e[1m1. Se va a revisar el parámetro de usuario de ejecución.\e[0m"
echo
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
echo "_____________________________________________________________________________________________________________________________________________________________________________________"
#2. Deshabilitar módulos innecesarios.
echo -e "\e[1m2. A continuación vamos a deshabilitar módulos innecesarios.\e[0m"
echo
echo "Se van a mostrar los módulos habilitados en apache: "
sudo apachectl -M
sudo apachectl -M | grep "^.*autoindex.*"
if [[ $? -eq 0 ]]
	then
		read -p "El módulo autoindex está activado, ¿desea desactivarlo? [S/N] " answer
		if [[ $answer =~ [sS] ]]
		then
			echo "Se va a desactivar el módulo autoindex"
			echo "Yes, do as I say!" | sudo a2dismod autoindex
		read -p "Para efectuar los cambios realizados, tendrá que reiniciar el servicio de apache, ¿desea hacerlo ahora? [S/N]" answer2
			if [[ $answer2 =~ [sS] ]]
			then
				echo "Se va a reiniciar el servicio."
				service apache2 restart
			else
				echo "No se reiniciará el servicio."
			fi
		fi
		else
			echo "El módulo se mantendrá activado."
	fi	
echo "_____________________________________________________________________________________________________________________________________________________________________________________"
#3. Ocultar información del servidor.
echo -e "\e[1m2. Ahora vamos a deshabilitar algunos parámetros para evitar mostrar información sensible.\e[0m"
echo ""
grep "^ServerTokens.*OS" $fichapa3Real
#Se han realizado cambios=1, no se han realizado cambios=0
cambios=0
if [[ $? -eq 0 ]]
then	
	echo "El parámetro Server Tokens está activado (OS), esto es peligroso para la seguridad de nuestro LAMP por lo que a continuación la desactivaremos."
	echo ""
	grep "^ServerTokens.*" $fichapa3Real >null
	sed -i 's/^ServerTokens.*OS$/ServerTokens ProductOnly/' $fichapa3Real
	cambios=1
	echo ""
	echo "Se ha modificado el archivo de configuración de seguridad desactivando el parámetro ServerTokens"
	echo ""
else
	echo "El parámetro ServerTokens está desactivado (ProductOnly) en el archivo de configuración seguridad, ¡buen trabajo!"
fi
grep "^ServerSignature.*On" $fichapa3Real
if [[ $? -eq 0 ]]
then	
	echo "El parámetro Server Signature está activado (On), esto es peligroso para la seguridad de nuestro LAMP por lo que a continuación la desactivaremos."
	echo ""
	grep "^ServerSignature.*" $fichapa3Real >null
	sed -i 's/^ServerSignature.*On$/ServerSignature Off/' $fichapa3Real
	cambios=1
	echo ""
	echo "Se ha modificado el archivo de configuración de seguridad desactivando el parámetro ServerSignature"
	echo ""
else
	echo "El parámetro ServerSignature está desactivado (ProductOnly) en el archivo de configuración seguridad, ¡buen trabajo!"
fi
if [[ $cambios -eq 1 ]]
then
	read -p "Para efectuar los cambios realizados, tendrá que reiniciar el servicio de apache, ¿desea hacerlo ahora? [S/N]" answer2
	if [[ $answer2 =~ [sS] ]]
	then
		echo "Se va a reiniciar el servicio."
		service apache2 restart
	else
		echo "Los cambios no serán efectivos hasta que reinicie el servicio de apache."
	fi
fi
echo "_____________________________________________________________________________________________________________________________________________________________________________________"
exit 
