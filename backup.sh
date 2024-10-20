#!/bin/bash

# Verifica se o utilizador introduziu exatamente dois argumentos
if [ $# -ne 2 ]     # '$#' indica o número de argumentos passados para o script 
then
    echo "Uso: $0 <diretorio.origem> <diretorio.backup>"
    exit 1
fi

ORIGEM="$1"
BACKUP="$2"

# Verifica se a origem é uma diretoria
if [ ! -d "$ORIGEM" ]
then
    echo "A diretoria origem não existe"
    exit 1
fi

# Verifica se o backup é uma diretoria
if [ ! -d "$BACKUP" ]
then
    echo "A diretoria backup não existe. A criar..."
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
sincronizar_arquivos
