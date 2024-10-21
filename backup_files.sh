#!/bin/bash

# Verifica se o utilizador introduziu menos de dois ou mais que 3 argumentos
if [ $# -lt 2 ] || [ $# -gt 3 ]     # '$#' indica o número de argumentos passados para o script 
then
    echo "Usage: $0 [-c] <source.directory> <backup.directory>"
    exit 1
fi

# Verifica se, para 3 argumentos o primeiro argumento é '-c'
CHECK=false                         # Check vai ser o valor booleano que indica se o utilizador pretende fazer "checking" do backup
if [[ $# -eq 3 ]] && [[ "$1" == "-c" ]] 
then
    CHECK=true
    ORIGEM="$2"
    BACKUP="$3"

# Caso o primeiro argumento não seja '-c', sai do programa
elif [[ $# -eq 3]] && [[ "$1" != "-c" ]]
then
    echo "Usage: $0 [-c] <source.directory> <backup.directory>"
    exit 1

# Caso só tenha dois argumentos:
else
    ORIGEM="$1"
    BACKUP="$2"
fi

# Verifica se a origem não é uma diretoria e consequencialmente se não existe
if [ ! -d "$ORIGEM" ]
then
    echo "The source directory does not exist."
    exit 1
fi

# Verifica se o backup não é uma diretoria e consequencialmente se não existe
if [ ! -d "$BACKUP" ]
then
    echo "The backup directory does not exist. Creating one..."
    l
    if [[ "$CHECK" == false ]]
    then
        mkdir -p "$BACKUP"      # Cria a diretoria. Caso as diretorias 'acima' não existam, estas serão criadas também
    fi
    echo "mkdir -p $BACKUP"
fi

# Verifica as permissões (escrita no backup e leitura na origem)
if [ ! -w "$BACKUP" ] || [ ! -r "$ORIGEM" ]
then
    echo "Check the writing permissions on the backup directory or the reading permissions from the source"
    exit 2
fi

source ./functs1.sh

sincronizar_arquivos "$CHECK"
remover_arquivos_inexistentes "$CHECK"

echo "Backup done!"
