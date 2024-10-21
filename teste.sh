#!/bin/bash

# Verifica se o utilizador introduziu exatamente dois argumentos
if [ $# -ne 2 ]     # '$#' indica o número de argumentos passados para o script 
then
    echo "Usage: $0 <source.directory> <backup.directory>"
    exit 1
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
    echo "mkdir -p $BACKUP"
    mkdir -p "$BACKUP"      # Cria a diretoria. Caso as diretorias 'acima' não existam, estas serão criadas também
fi

if [ ! -w "$BACKUP" ] || [ ! -r "$ORIGEM" ]
then
    echo "Erro nas permissões:"

    if [ ! -w "$BACKUP" ]
    then
        echo "- A diretoria de backup '$BACKUP' não tem permissões de escrita. Use o comando 'chmod' para conceder permissões."
    if

    if [ ! -r "$ORIGEM" ]
    then
        echo "- A diretoria de origem '$ORIGEM' não tem permissões de leitura. Verifique e ajuste as permissões."
    fi

    exit 2
fi

source ./functs.sh

ERROS=0
AVISOS=0
COPIAS=0
ATUALIZS=0
APAGADOS=0
SIZE_COPIED=0
SIZE_DELETED=0

sincronizar_arquivos
remover_arquivos_inexistentes

echo "Backup done!"
