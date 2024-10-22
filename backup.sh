#!/bin/bash

usage() {
    echo "Usage: $0 [-c] [-b tfile] [-r regexpr] <source_directory> <backup_directory>"
    exit 1
}

sincronizar_arquivos() {

    echo "Sincronizing new files and modified ones..."

    excluded_files=()        # Inicializa a lista que vai guardar os ficheiros a exluir

    # Verifica se a lista não está vazia (-n) e se o ficheiro existe (-f)
    if [[ -n "$EXCLUDE_LIST" ]] && [[ -f "$EXCLUDE_LIST" ]]
    then
        while IFS= read -r line || [ -n "$line" ]
        do
            excluded_files+=($line)
        done < "$EXCLUDE_LIST"
    fi

    # Procura apenas ficheiros na origem / O input introduzido no read sera o output do find e será guardado na variavel item
    find "$ORIGEM" -type d -o -type f | while read -r item
    do

        # Verifica se o nome base do arquivo na origem é igual a algum ficheiro na lista de ficheiros a excluir
        if [[ "${excluded_files[@]}" =~ $(basename "$arquivo") ]]
        then
            continue
        fi

        # Verifica se a regex não está vazia e se nome base do arquivo na origem é diferente da regex
        if [[ -n "$REGEX" ]] && [[ ! "$(basename "$arquivo")" =~ $REGEX ]]
        then
            continue
        fi

        # Manipula o valor da variavel item para ser o caminho do backup
        backup="$BACKUP/${item#$ORIGEM}"         # Usamos parametros de expansao para trocar o caminho do item pelo caminho do backup

        # Verifica se o ficheiro existe ou o item é mais recente que o backup
        if [[ -d "$item" ]]      # Verifica se o item é uma diretoria
        then                        
            if [[ "$CHECK" == false ]]       # Verifica se está no modo checking
            then
                mkdir -p $backup    
            fi
            echo "mkdir -p $backup"

            # Chama se a si própria recursivamente
            sincronizar_arquivos ${CHECK:+-c} ${EXCLUDE_LIST:+-b "$EXCLUDE_LIST"} ${REGEX:+-r "$REGEX"} "$item" "$backup"
        else
            if [ ! -e "$backup" ] || [ "$item" -nt "$backup" ]       # '-nt' = newer than
            then 
                if [[ "$CHECK" == false ]]
                then
                    cp -a "$item" "$backup"      # Faz a copia do item preservando todos os atributos (-a)  
                fi
                echo "cp -a $item $backup"
            fi   
        fi
    done
}

remover_arquivos_inexistentes() {

    echo "Removing non-existing files..."

    find "$BACKUP" -maxdepth 1 -type f | while read -r arquivo
    do
        origem="$ORIGEM/${arquivo#BACKUP}"
        
        if [ ! -e "$origem" ]       # Verifica se o arquivo origem existe no arquivo backup
        then                        # Caso não exista, irá eliminá-lo da do backup tambem
            if [[ "$CHECK" == false ]]
            then
            	rm "$arquivo"     
            fi
            echo "rm $arquivo"
        fi
    done 
}

CHECK=false # Check vai ser o valor booleano que indica se o utilizador pretende fazer "checking" do backup
EXCLUDE_LIST=""
REGEX=""
                                        # : atrás é uma convenção usada para lidar com erros em bash de forma efetiva
                                        # todos os comandos seguido de um : indica que recebe argumentos
while getopts ":cb:r:" opt              # getopts é uma utilidade built in que simplifica parsing flags
do
    case "$opt" in
        c) CHECK=true ;;
        b) EXCLUDE_LIST="$OPTARG" ;;        # "$OPTARG" é uma variável especial que recebe o argumento da opção atual
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


sincronizar_arquivos 
remover_arquivos_inexistentes 

echo "Backup done!"

