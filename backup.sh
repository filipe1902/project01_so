#!/bin/bash

# Verifica se o utilizador introduziu exatamente dois argumentos
if [ $# -lt 2 ] || [ $# -gt 3 ]     # '$#' indica o número de argumentos passados para o script 
then
    echo "Usage: $0 [-c] <source.directory> <backup.directory>"
    exit 1
fi

# Verifica se o primeiro argumento é '-c'
CHECK=false
if [[ $# -e 3 ]] && [[ "$1" == "-c" ]] 
then
    CHECK=true
    ORIGEM="$2"
    BACKUP="$3"
else
    ORIGEM="$1"
    BACKUP="$2"
fi

ORIGEM="$1"
BACKUP="$2"

# Verifica se a origem é uma diretoria
if [ ! -d "$ORIGEM" ]
then
    echo "The source directory does not exist."
    exit 1  
fi

# Verifica se o backup é uma diretoria
if [ ! -d "$BACKUP" ]
then
    echo "The backup directory does not exist. Creating one..."
    
    if [[ "$CHECK" == true ]]
    then
        echo "mkdir -p $BACKUP"
    else
        mkdir -p "$BACKUP"      # Cria a diretoria. Caso as diretorias 'acima' não existam, estas serão criadas também
        echo "mkdir -p $BACKUP"
    fi
fi

# Verifica as permissões
if [ ! -w "$BACKUP" ] || [ ! -r "$ORIGEM" ]
then
    echo "Check the writing permissions on the backup directory or the reading permissions from the source"
    exit 2
fi

source ./functs2.sh

sincronizar_arquivos "$CHECK"
remover_arquivos_inexistentes "$CHECK"

echo "Backup done!"