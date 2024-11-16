#!/bin/bash

usage() {
    echo "Usage: $0 <source_directory> <backup_directory>"
    exit 1
}

sincronizar_arquivos() {
    local ORIGEM="$4"
    local BACKUP="$5"

    for item in $ORIGEM/*; do
    
        nome_item=$(basename "$item")
        backup="$BACKUP${item#$ORIGEM}" 

        relative_backup=${backup#"$(dirname $BACKUPOG)/"}
        relative_item=${item#"$(dirname $ORIGEMOG)/"}

        if [[ "$item" == "$ORIGEM/*" ]]
        then 
            continue
        fi

        if [[ ! -r "$item" ]]
        then
            echo "ERROR: "$relative_item" does not have reading permissions."
            continue
        fi

        if [[ -e "$backup" && ! -w "$backup" ]]
        then
            echo "ERROR: "$relative_backup" does not have writing permissions."
            continue
        fi        

        for exclude in "${excluded_files[@]}"     
        do  
            if [[ "$exclude" == "$nome_item" ]]     
            then
                continue 2                           
            fi
        done
        


        # Verifica a expressão regular se estiver definida
        if [[ -n "$REGEX" ]] && ! echo "$nome_item" | grep -qE "$REGEX"; then
            continue   
        fi

        if [[ -d "$item" ]]      
        then
            if [[ ! -d $backup ]]
            then                   
                if [[ "$CHECK" == false ]]       
                then
                    mkdir $backup 
                fi
                echo "mkdir ${backup#"$(dirname $BACKUPOG)/"}"
            fi

            sincronizar_arquivos "$CHECK" "$EXCLUDE_LIST" "$REGEX" "$item" "$backup"

        elif [[ -f "$item" ]]
        then
            if [ ! -e "$backup" ] || [ "$item" -nt "$backup" ]      
            then 
                if [[ "$CHECK" == false ]]
                then
                    cp -a "$item" "$backup"     
                fi
                echo "cp -a ${item#"$(dirname $ORIGEMOG)/"} ${backup#"$(dirname $BACKUPOG)/"}"
            fi   
        fi
    done
}

remover_arquivos_inexistentes() {

    local ORIGEM="$2"
    local BACKUP="$3"

    for item in "$BACKUP"/*
    do
    
        if [[ "$item" == "$BACKUP" ]]
        then
            continue
        fi 

        origem="$ORIGEM/${item#$BACKUP/}"

        if [[ -d "$item" ]]
        then
            if [[ ! -d "$origem" ]]
            then
                if [[ "$CHECK" == false ]]
                then
                    rm -rf "$item"
                fi

                continue
            fi

            remover_arquivos_inexistentes "$CHECK" "$origem" "$item"
        elif [[ -f "$item" ]]
        then
            if [[ ! -f "$origem" ]]
            then
                if [[ "$CHECK" == false ]]
                then
                    rm "$item"
                fi
            fi
        fi
    done
}


CHECK=false                          
EXCLUDE_LIST=""
REGEX=""
excluded_files=()                       
                                        
                                   
while getopts ":cb:r:" opt              
do
    case "$opt" in
        c) CHECK=true ;;
        b) EXCLUDE_LIST="$OPTARG" ;;        
        r) REGEX="$OPTARG" ;;       
        *) usage ;;                      
    esac
done
                                       
shift $((OPTIND - 1))                   
                                        
if [ $# -ne 2 ]; then
    usage
fi

ORIGEMOG="$1"
BACKUPOG="$2"

if [ ! -d "$ORIGEMOG" ]
then
    echo "$1 is not a directory"
    exit 1
fi

if [ ! -d "$BACKUPOG" ]
then
    if [[ "$CHECK" == false ]]
    then
        mkdir -p "$BACKUPOG"   
    fi
    echo "mkdir ${BACKUPOG#"$(dirname $BACKUPOG)/"}"
fi


if ([ ! -w "$BACKUPOG" ] || [ ! -r "$ORIGEMOG" ]) && [[ $CHECK == false ]]
then
    echo "Error in permissions"
    exit 2
fi

if [[ -n "$EXCLUDE_LIST" ]]        
then
    while IFS= read -r line || [[ -n "$line" ]];
    do  
        line=$(echo "$line" | xargs)
        excluded_files+=("$line")
    done < "$EXCLUDE_LIST"
fi

sincronizar_arquivos "$CHECK" "$EXCLUDE_LIST" "$REGEX" "$ORIGEMOG" "$BACKUPOG"
if [[ -e "$BACKUPOG" ]]
then
    remover_arquivos_inexistentes "$CHECK" "$ORIGEMOG" "$BACKUPOG"
fi

