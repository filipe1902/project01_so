#!/bin/bash

sincronizar_arquivos() {
    # Loop para iterar sobre cada arquivo na diretoria origem - sem find
    for arquivo in "$ORIGEMOG"/*; do
        
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

    # Loop para iterar sobre cada diretoria na diretoria backup
    for dir in "$BACKUPOG"/*; do
        if [ -d "$dir" ] && [ -z "$(ls -A "$dir")" ]; then
            rmdir "$dir"  
            echo "rm ${arquivo#"$(dirname "$BACKUPOG")/"}"
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

# Verifica se a origem não é uma diretoria e, consequentemente, se não existe
if [ ! -d "$ORIGEMOG" ]; then
    exit 1
fi

# Verifica se o backup não é uma diretoria e, consequentemente, se não existe
if [ ! -d "$BACKUPOG" ]; then
    if [[ "$CHECK" == false ]]; then
        mkdir -p "$BACKUPOG"  # Cria a diretoria. Caso as diretorias 'acima' não existam, estas serão criadas também
    fi
    echo "mkdir -p ${BACKUPOG#"$(dirname "$BACKUPOG")/"}"
fi

# Verifica as permissões (escrita no backup e leitura na origem)
if ([ ! -w "$BACKUPOG" ] || [ ! -r "$ORIGEMOG" ]) && [[ $CHECK == false ]]; then
    exit 2
fi

sincronizar_arquivos

# Verifica se o backup existe
if [[ -d "$BACKUPOG" ]]; then
    remover_arquivos_inexistentes
fi
