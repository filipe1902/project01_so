#!/bin/bash

sincronizar_arquivos() {
    # Loop para iterar sobre cada arquivo na diretoria origem - sem find
    for arquivo in "$ORIGEMOG"/*; do
        
        relative_backup=${backup#"$(dirname $BACKUPOG)/"}
        relative_item=${arquivo#"$(dirname $ORIGEMOG)/"}

        if [[ "$arquivo" == "$ORIGEM/*" ]]
        then 
            continue
        fi

        if [[ ! -r "$arquivo" ]]
        then
            echo "ERROR: "$relative_item" does not have reading permissions."
            continue
        fi

        if [[ -e "$backup" && ! -w "$backup" ]]
        then
            echo "ERROR: "$relative_backup" does not have writing permissions."
            continue
        fi

        if [ -f "$arquivo" ]; then
            
            backup="$BACKUPOG${arquivo#$ORIGEMOG}"

            if [ ! -e "$backup" ] || [ "$arquivo" -nt "$backup" ]; then
                if [[ "$CHECK" == false ]]; then
                    cp -a "$arquivo" "$backup" 
                fi
                echo "cp -a ${arquivo#"$(dirname "$ORIGEMOG")/"} ${backup#"$(dirname "$BACKUPOG")/"}"
            fi
        fi
    done
}

remover_arquivos_inexistentes() {
    # Loop para iterar sobre cada ficheiro na diretoria de backup 
    for arquivo in "$BACKUPOG"/*; do

        if [ -f "$arquivo" ]; then

            origem="$ORIGEMOG/${arquivo#$BACKUPOG}"

            if [ ! -e "$origem" ]; then
                if [[ "$CHECK" == false ]]; then
                    rm "$arquivo"  
                fi
                echo "rm ${arquivo#"$(dirname "$BACKUPOG")/"}"
            fi
        fi
    done
}

if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    echo "Usage: $0 [-c] <source.directory> <backup.directory>"
    exit 1
fi

CHECK=false  
if [[ $# -eq 3 ]] && [[ "$1" == "-c" ]]; then
    CHECK=true
    ORIGEMOG="$2"
    BACKUPOG="$3"

elif [[ $# -eq 3 ]] && [[ "$1" != "-c" ]]; then
    echo "Usage: $0 [-c] <source.directory> <backup.directory>"
    exit 1

else
    ORIGEMOG="$1"
    BACKUPOG="$2"
fi

if [ ! -d "$ORIGEMOG" ]; then
    echo "Usage: $0 [-c] <source.directory> <backup.directory>"
    exit 1
fi

if [ ! -d "$BACKUPOG" ]; then
    if [[ "$CHECK" == false ]]; then
        mkdir -p "$BACKUPOG"  
    fi
    echo "mkdir -p ${BACKUPOG#"$(dirname "$BACKUPOG")/"}"
fi

if ([ ! -w "$BACKUPOG" ] || [ ! -r "$ORIGEMOG" ]) && [[ $CHECK == false ]]; then
    echo "ERROR: Check "$ORIGEMOG" reading permissions or "$BACKUPOG" writing permissions"
    exit 2
fi

sincronizar_arquivos

if [[ -d "$BACKUPOG" ]]; then
    remover_arquivos_inexistentes
fi
