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
fichphpReal="/etc/php/8.1/apache2/php.ini"
fichphpPrueba="sandbox/php.ini"

fichphpReal=$fichphpPrueba
#1. Desactivar php_expose.
echo -e "\e[1m1. Se va a revisar el parámetro de expose_php está desactivado (Off) en el archivo de configuración php.ini.\e[0m"
echo ""
grep "expose_php.*=.*Off" $fichphpReal
if [[ $? -ne 0 ]]
then	
	echo "El parámetro expose_php está activado (On) en el archivo de configuración php.ini, esto es peligroso para la seguridad de nuestro LAMP por lo que a continuación la desactivaremos."
	echo ""
	echo "Estado actual del parámetro en el fichero: "; grep "^expose_php.*=.*$" $fichphpReal
	sed -i 's/^expose_php.*=.*On$/expose_php = Off/' $fichphpReal
	echo ""
	echo "Se ha modificado el archivo de configuración de php.ini desactivando el parámetro de expose_php"
	echo ""
	echo "Estado actual del parámetro en el fichero: "; grep "^expose_php.*=.*$" $fichphpReal
else
	echo "El parámetro expose_ php está desactivado (Off) en el archivo de configuración php.ini, ¡buen trabajo!"
fi
echo "_____________________________________________________________________________________________________________________________________________________________________________________"
#2. Desactivar display_errors.
echo -e "\e[1m2. Se va a revisar el parámetro de display_errors.\e[0m"
echo ""
grep "display_errors.*=.*Off" $fichphpReal
if [[ $? -ne 0 ]]
then	
	echo "El parámetro display_errors está activado (On) en el archivo de configuración php.ini, esto es peligroso para la seguridad de nuestro LAMP por lo que a continuación la desactivaremos."
	echo ""
	echo "Estado actual del parámetro en el fichero: "; grep "^display_errors.*=.*$" $fichphpReal
	sed -i 's/^display_errors.*=.*On$/display_errors = Off/' $fichphpReal
	echo ""
	echo "Se ha modificado el archivo de configuración de php.ini desactivando el parámetro de display_errors"
	echo ""
	echo "Estado actual del parámetro en el fichero: "; grep "^display_errors.*=.*$" $fichphpReal
else
	echo "El parámetro display_errors está desactivado (Off) en el archivo de configuración php.ini, ¡buen trabajo!"
fi
echo "_____________________________________________________________________________________________________________________________________________________________________________________"
#3. Funcionamiento open_basedir.
echo -e "\e[1m3. Se va a comprobar el estado del parámetro open_basedir.\e[0m"
echo ""
grep "^;open_basedir.*=.*$" $fichphpReal
if [[ $? -ne 0 ]]
then	
	echo "El parámetro open_basedir está activado."
	echo ""
	echo "Estado actual del parámetro en el fichero: "; grep "^open_basedir.*=.*$" $fichphpReal
	echo ""
else
	read -p "El parámetro open_basedir está desactivado, ¿desea activarlo? [s/n]: " answer
	
	if [[ $answer =~ [sS] ]]
		then
			until [ -d "$dir" ]
			do
			read -p "Se va a activar el parámetro open_basedir, por favor escriba un nombre de directorio válido al que se va a aplicar: " dir
			done
			sed -i "s#^;.*open_basedir.*=.*#open_basedir = ${dir}#" $fichphpReal
			echo "Estado actual del parámetro en el fichero php.ini: "; grep "^open_basedir.*=.*$" $fichphpReal
		else
			echo "La directiva se mantendrá desactivada."
	fi			
fi
echo "_____________________________________________________________________________________________________________________________________________________________________________________"
#4. disable_functions.
echo -e "\e[1m4. Se va a revisar el parámetro disable_functions.\e[0m"

funciones=( "phpinfo" "system" "exec" "shell_exec" "ini_set" "dl" "eval" )
grep "^;disable_functions.*=.*$" $fichphpReal > /dev/null
if [[ $? -ne 0 ]]
then	
	echo "El parámetro disable_functions está activado."
	echo ""
	echo "Estado actual del parámetro en el fichero: "; grep "^disable_functions.*=.*" $fichphpReal
	echo ""
	echo "Se recomienda deshabilitar las siguientes funciones: ${funciones[@]}"
else
	echo "El parámetro disable_functions está desactivado. Le recomendamos deshabilitar algunas funciones, a continuación: "
	read -p "Desea activarlo? [s/n]: " addfunct
	while [[ $addfunct != s ]] && [[ $addfunct != n ]];
	do
		read -p "Introduzca una opción correcta [s/n]: " addfunct
	done
	if [[ "$addfunct"  =~ [sS] ]]
	then
		sed -i "s/^;disable_functions.*=.*/disable_functions = /" $fichphpReal
		#echo "Estado actual del parámetro en el fichero: "; grep "^disable_functions.*=.*" $fichphpReal
		for funcion in "${funciones[@]}"
		do
			read -p "Desea añadir la función $funcion? [s/n]: " addfunct
			while [[ $addfunct != s ]] && [[ $addfunct != n ]];
			do
				read -p "Introduzca una opción correcta [s/n]: " addfunct
			done
			if [[ "$addfunct"  =~ [sS] ]]
			then
				linea=$(grep "^disable_functions.*=.*" $fichphpReal)
				addline="$linea $funcion,"
				sed -i "s#^disable_functions.*=.*#${addline}#" $fichphpReal
			else
				echo "De acuerdo, se omitirá $funcion y se pasará a la siguiente función."
			fi
		done
		echo "Se han añadido correctamente las funciones que deben estar deshabilitadas."
		echo "Estado actual del parámetro en el fichero: "; grep "^disable_functions.*=.*$" $fichphpReal
	else
		echo "De acuerdo, el parámetro se quedará desactivado"
	fi	
	
	
fi
echo "_____________________________________________________________________________________________________________________________________________________________________________________"

#5.Remote File Inclusion.
echo -e "\e[1m5. Se van a revisar los parámetros necesarios para evitar los archivos alojados en servidores externos.\e[0m"
echo
echo "Primero revisaremos el estado de allow_url_fopen"
grep "allow_url_fopen.*=.*Off" $fichphpReal
if [[ $? -ne 0 ]]
then	
	echo "El parámetro allow_url_fopen está activado (On) por lo que a continuación la desactivaremos."; grep "^allow_url_fopen.*=.*$" $fichphpReal
	echo "A continuación se va a desactivar por su seguridad."
	sed -i 's/^allow_url_fopen.*=.*On$/allow_url_fopen = Off/' $fichphpReal
	echo ""
	echo "Se ha modificado el archivo de configuración de php.ini desactivando el parámetro de allow_url_fopen"; grep "^allow_url_fopen.*=.*$" $fichphpReal
	echo
else
	echo "El parámetro allow_url_fopen está desactivado (Off) en el archivo de configuración php.ini, ¡buen trabajo!"
	echo
fi
echo
echo "Ahora comprobaremos el estado del parámetro allow_url_include"
grep "allow_url_include.*=.*Off" $fichphpReal
if [[ $? -ne 0 ]]
then	
	echo "El parámetro allow_url_include está activado (On) por lo que a continuación lo desactivaremos."; grep "^allow_url_include.*=.*$" $fichphpReal
	echo "A continuación se va a desactivar por su seguridad."
	sed -i 's/^allow_url_include.*=.*On$/allow_url_include = Off/' $fichphpReal
	echo ""
	echo "Se ha modificado el archivo de configuración de php.ini desactivando el parámetro de allow_url_include"; grep "^allow_url_include.*=.*$" $fichphpReal
	echo
else
	echo "El parámetro allow_url_include está desactivado (Off) en el archivo de configuración php.ini, ¡buen trabajo!"
fi
echo "_____________________________________________________________________________________________________________________________________________________________________________________"
exit 0
