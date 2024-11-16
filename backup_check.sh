#!/bin/bash

usage() {
    echo "Usage: $0 <source_directory> <backup_directory>"
    exit 1
}

check_files() {
    local ORIGEM="$1"
    local BACKUP="$2"

    for item in "$ORIGEM"/*; do
    
        nome_item=$(basename "$item")
        backup="$BACKUP${item#$ORIGEM}"     

        relative_backup="${backup#"$(dirname $BACKUPOG)/"}"
        relative_item="${item#"$(dirname $ORIGEMOG)/"}"
    
        if [[ -d "$item" ]]; then     
            if [[ -d "$backup" ]]; then

                check_files "$item" "$backup"

            else 
              
                echo "Directory $relative_backup does not exist"
            fi

        elif [[ -f "$item" ]]; then
            if [[ -f "$backup" ]]; then                                                                # md5sum calcula o MD5 checksum do item 
                source_check=$(md5sum "$item" | awk '{print $1}')               # o output do md5sum é o hash e nome do item em questão logo
                backup_check=$(md5sum "$backup" | awk '{print $1}')        # usa se para extrair o primeiro campo do output, que é o hash do item

                if [[ "$source_check" != "$backup_check" ]]; then                     # aqui verificamos se o hash do item é diferente ao do seu backup
                   
                    echo "File $relative_item and $relative_backup differ"
                fi 
            else
                
                echo "File $relative_backup does not exist"
            fi   
        fi
    done
}

if [ $# -ne 2 ]; then
    usage
fi

ORIGEMOG="$1"
BACKUPOG="$2"


if [ ! -d "$ORIGEMOG" ]; then
    echo "$1 is not a directory"
    exit 1
fi


if [ ! -d "$BACKUPOG" ]; then
    echo "$2 is not a directory"
    exit 1
fi

check_files "$ORIGEMOG" "$BACKUPOG"

