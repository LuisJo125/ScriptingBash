#!/bin/bash
#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


function ctrl_c(){
  echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
  tput cnorm && exit 1
}

#ctrl+c
trap ctrl_c INT

#Variables globales
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel(){
  echo -e "\n\n${yellowColour}[+]${endColour}${grayColour} Uso: ${endColour}"
  echo -e "\t${purpleColour}m)${endColour}${grayColour} Buscar por un nombre de maquina${endColour}"
  echo -e "\t${purpleColour}i)${endColour}${grayColour} Buscar por dirección IP${endColour}"
  echo -e "\t${purpleColour}y)${endColour}${grayColour} Buscar por nombre el link de You Tube${endColour}"
  echo -e "\t${purpleColour}d)${endColour}${grayColour} Buscar por dificultad${endColour}"
  echo -e "\t${purpleColour}o)${endcolour}${grayColour} buscar por sistema operativo${endcolour}"
  echo -e "\t${purpleColour}s)${endcolour}${grayColour} buscar por skills${endcolour}"
  echo -e "\t${purpleColour}h)${endColour}${grayColour} Mostrar este panel de ayuda${endColour}"
  echo -e "\t${purpleColour}u)${endColour}${grayColour} Descargar o actualizar archivos necesarios${endColour}"
}


function updateFiles(){
  tput civis

  if [ ! -f bundle.js ]; then 
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Descargando archivos necesarios...${endColour}"
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Todos los archivos fueron descargados...${endColour}"
  else
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Verificando actualizaciones... ${endColour}"
    curl -s $main_url > bundle_temp.js
    js-beautify bundle_temp.js | sponge bundle_temp.js
    md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
    md5_original_value=$(md5sum bundle.js | awk '{print $1}')
    
    if [ "$md5_original_value" == "$md5_temp_value" ]; then
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} No se han detectado actualizaciones, todo esta al dia ;)${endColour}"
      rm bundle_temp.js
    else
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Se han encontrado actualizaciones disponibles ${endColour}"
      sleep 1
      rm bundle.js && mv bundle_temp.js bundle.js
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Actualizaciones aplicadas correctamente${endColour}"
    fi
  fi
  tput cnorm
}

function searchMachine(){
  machineName="$1"
  machineName_checker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//')"
  
  if [ "$machineName_checker" ]; then

   echo -e "\n${yellowColour}[+]${endColour}${yellowColour} Listando las propiedades de la máquina ${endColour}${blueColour}$machineName${endColour}${grayColour}:${endColour}\n"

   cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//'
  else
   echo -e "\n${yellowColour}[!]${endColour}${grayColour} No existe ninguna maquina con ese nombre${endColour}"
  fi
} 

function searchIP(){
  ipAddress="$1"
  machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"
  
  if [ "$machineName" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour}La ip: ${blueColour}$ipAddress${endColour} corresponde a la maquina: ${purpleColour}$machineName${endColour}\n"
  else
    echo -e "\n${yellowColour}[!]${endColour}${grayColour} No existe ninguna maquina con esa ip${endColour}"
  fi
  
}

function getYouTubeLink(){
  machineName="$1"
  
  linkYouTube="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep youtube | awk 'NF{print $NF}'\n)"

  if [ "$linkYouTube" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} El link de la maquina $machineName es: ${endColour}${blueColour}$linkYouTube${endColour}"
  else
    echo -e "\n${yellowColour}[!]${endColour}${grayColour} No existe ninguna maquina con ese nombre${endColour}"
  fi
}

function selectColorDificulty(){
  dificulty="$1"
  if [ "$dificulty" == "Fácil" ]; then
     dificulty="$(echo -e "${grayColour}$dificulty${endColour}")"
  elif [ "$dificulty" == "Media" ]; then
    dificulty="$(echo -e "${greenColour}$dificulty${endColour}")"
  elif [ "$dificulty" == "Difícil" ]; then
    dificulty="$(echo -e "${purpleColour}$dificulty${endColour}")"
  elif [ "$dificulty" == "Insane" ]; then
    dificulty="$(echo -e "${redColour}$dificulty${endColour}")"
  else
    echo "$dificulty"
  fi

  echo -e "$dificulty"
}

function searchDificulty(){
  dificulty="$1"
  
  result=$(cat bundle.js | grep "dificultad: \"$dificulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)
  dificulty_colored=$(selectColorDificulty "$dificulty")

  if [ "$result" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Todas las maquinas de dificultad ${endColour}$dificulty_colored\n ${grayColour}$result${endColour}"
  else
    echo -e "\n${yellowColour}[!]${endColour}${grayColour} No existe ese nivel de dificultad${endColour}"
  fi
}

function searchSystem(){
  system="$1"

  result="$(cat bundle.js | grep "so: \"$system\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column )"
  if [ "$system" == "Linux" ]; then
    system="$(echo -e "${blueColour}$system${endColour}")"
  elif [ "$system" == "Windows" ]; then
     system="$(echo -e "${greenColour}$system${endColour}")"
  fi
  
  if [ "$result" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Todas las maquinas con el sistema operativo ${endColour}$system\n ${grayColour}$result${endColour}"
  else
    echo -e "\n${yellowColour}[!]${endColour}${grayColour} No existe ese sistema operativo${endColour}"
  fi

}

function getOSDifficultyMachines(){
  dificulty="$1"
  system="$2"
  
  result="$(cat bundle.js | grep "so: \"$system\"" -C 4 | grep "dificultad: \"$dificulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column )"
  
  if [ "$system" == "Linux" ]; then
    system="$(echo -e "${blueColour}$system${endColour}")"
  elif [ "$system" == "Windows" ]; then
     system="$(echo -e "${greenColour}$system${endColour}")"
  fi
  dificulty_colored=$(selectColorDificulty "$dificulty")

  if [ "$result" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Estas son todas las maquinas con SO ${endColour}$system ${grayColour} con dificultad ${endColour} $dificulty_colored\n ${grayColour}$result${endColour}"
  else
    echo -e "\n${yellowColour}[!]${endColour}${grayColour} Los parametros no estan bien definidos${endColour}"
  fi
}

function searchSkills(){
  skill="$1"
  result=$(cat bundle.js | grep "skills: " -B 6 | grep "$skill" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)
  if [ "$result" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Todas las maquinas con la skill ${endColour}${purpleColour}$skill${endColour}\n ${grayColour}$result${endColour}"
  else
    echo -e "\n${yellowColour}[!]${endColour}${grayColour} No existe ninguna skill llamda asi $skill ${endColour}"
  fi

}

# Indicadores
declare -i parameter_counter=0

#Chivato
declare -i chivato_difficulty=0
declare -i chivato_os=0

while getopts "m:ui:y:d:o:s:h" arg; do
  case $arg in
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAddress="$OPTARG"; let parameter_counter+=3;;
    y) machineName="$OPTARG"; let parameter_counter+=4;;
    d) dificulty="$OPTARG"; chivato_difficulty=1; let parameter_counter+=5;;
    o) system="$OPTARG"; chivato_os=1; let parameter_counter+=6;;
    s) skill="$OPTARG"; let parameter_counter+=7;;
    h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
  updateFiles
elif [ $parameter_counter -eq 3 ]; then
  searchIP $ipAddress 
elif [ $parameter_counter -eq 4 ]; then
  getYouTubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
  searchDificulty $dificulty
elif [ $parameter_counter -eq 6 ]; then
  searchSystem $system
elif [ $chivato_difficulty -eq 1 ] && [ $chivato_os -eq 1 ]; then
  getOSDifficultyMachines $dificulty $system
elif [ $parameter_counter -eq 7 ]; then
  searchSkills "$skill"
else
  helpPanel
fi
