#!/bin/bash

usage() {
    echo "Usage: $0 [-c] [-b tfile] [-r regexpr] <source_directory> <backup_directory>"
    exit 1
}

CHECK=false # Check vai ser o valor booleano que indica se o utilizador pretende fazer "checking" do backup
DELETE_LIST=""
REGEX=""
                                        # : atrás é uma convenção usada para lidar com erros em bash de forma efetiva
                                        # todos os comandos seguido de um : indica que recebe argumentos
while getopts ":cb:r:" opt              # getopts é uma utilidade built in que simplifica parsing flags
do
    case "$opt" in
        c) CHECK=true ;;
        b) DELETE_LIST="$OPTARG" ;;        # "$OPTARG" é uma variável especial que recebe o argumento da opção atual
        r) REGEX="$OPTARG" ;;
        *) usage;;                      
    esac
done
                                        # OPTIND é uma variavel especial que aponta para o proximo argumento depois da ultima opcao
shift $((OPTIND - 1))                   # subtraimos 1 a OPTIND porque, sabemos que OPTIND aponta para o primeiro argumento obrigatorio
                                        # e nós queremos dar shift até ele e não passar por ele

if [ $# -ne 2 ]; then
    usage
fi

ORIGEM="$1"
BACKUP="$2"

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

source ./functs2.sh

sincronizar_arquivos "$CHECK" "$DELETE_LIST" "$REGEX" "$ORIGEM" "$BACKUP"
remover_arquivos_inexistentes "$CHECK" "$DELETE_LIST" "$REGEX" "$ORIGEM" "$BACKUP"

echo "Backup done!"
