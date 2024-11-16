#!/bin/bash

usage() {
    echo "Usage: $0 [-c] [-b tfile] [-r regexpr] <source_directory> <backup_directory>"
    exit 1
}

check_files() {
    local ORIGEM="$1"
    local BACKUP="$2"

    for item in "$ORIGEM"/*; do
    
        nome_item=$(basename "$item")

        # Manipula o valor da variavel item para ser o caminho do backup
        backup="$BACKUP${item#$ORIGEM}"         # Usamos parametros de expansao para trocar o caminho do item pelo caminho do backup

        relative_item="testes/${item#$ORIGEM/}"
        relative_backup="backup/${item#$ORIGEM/}"

        # Verifica se o ficheiro existe ou o item é mais recente que o backup
        if [[ -d "$item" ]]; then      # Verifica se o item é uma diretoria
            if [[ -d "$backup" ]]; then
                # Chama se a si própria recursivamente
                check_files "$item" "$backup"
            else 
                # nao existe
                echo "Directory $relative_backup does not exist"
            fi

        elif [[ -f "$item" ]]; then
            if [[ -f "$backup" ]]; then                                                                # md5sum calcula o MD5 checksum do item 
                source_check=$(md5sum "$item" | awk '{print $1}')               # o output do md5sum é o hash e nome do item em questão logo
                backup_check=$(md5sum "$backup" | awk '{print $1}')        # usa se para extrair o primeiro campo do output, que é o hash do item

                if [[ "$source_check" != "$backup_check" ]]; then                     # aqui verificamos se o hash do item é diferente ao do seu backup
                    # diferem
                    echo "File $relative_item and $relative_backup differ"
                fi 
            else
                # nao existe
                echo "File $relative_backup does not exist"
            fi   
        fi
    done
}

if [ $# -ne 2 ]; then
    usage
fi

ORIGEM="$1"
BACKUP="$2"

# Verifica se a origem não é uma diretoria e consequencialmente se não existe
if [ ! -d "$ORIGEM" ]; then
    echo "$1 is not a directory"
    exit 1
fi

# Verifica se o backup não é uma diretoria e consequencialmente se não existe
if [ ! -d "$BACKUP" ]; then
    echo "$2 is not a directory"
    exit 1
fi

check_files "$ORIGEM" "$BACKUP"

