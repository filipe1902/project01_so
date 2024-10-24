#!/bin/bash

usage() {
    echo "Usage: $0 [-c] [-b tfile] [-r regexpr] <source_directory> <backup_directory>"
    exit 1
}

sincronizar_arquivos() {
    local ORIGEM="$4"
    local BACKUP="$5"
    excluded_files=()        # Inicializa a lista que vai guardar os ficheiros a exluir

    # Verifica se a lista não está vazia (-n) e se o ficheiro existe (-f)
    #if [[ -n "$EXCLUDE_LIST" ]] && [[ -f "$EXCLUDE_LIST" ]] #tem que existir(-f) e não pode estar vazio(-n)
    #then
    #    while IFS= read -r line || [ -n "$line" ]   #lê todas as linhas até ao /n e se não tivessemos isto não lia a última linha
    #    do
    #        excluded_files+=($line)
    #    done < "$EXCLUDE_LIST"
    #fi #lista dos excluded_files com os nomes que não queremos copiar para o backup

    # find para procurar por diretórios (-type d) e arquivos (-type f) na diretoria de origem ("$ORIGEM"). Os resultados da busca são passados, um por um, para o loop while read -r item, onde item é o caminho completo de cada diretório ou arquivo encontrado.
    find "$ORIGEM" -type d -o -type f | while read -r item
    do
        
        # Verifica se o nome base do arquivo na origem é igual a algum ficheiro na lista de ficheiros a excluir
        #if [[ "${excluded_files[@]}" =~ $(basename "$arquivo") ]]
        #then
        #    continue
        #fi

        # Verifica se a regex não está vazia e se nome base do arquivo na origem é diferente da regex
        #if [[ -n "$REGEX" ]] && [[ ! "$(basename "$arquivo")" =~ $REGEX ]]
        #then
        #    continue
        #fi

        # Manipula o valor da variavel item para ser o caminho do backup
        backup="$BACKUP${item#$ORIGEM}"         # Usamos parametros de expansao para trocar o caminho do item pelo caminho do backup
        
        if [[ "$item" == "$ORIGEM" ]]
        then
            continue
        fi  

        # Verifica se o ficheiro existe ou o item é mais recente que o backup
        if [[ -d "$item" ]]      # Verifica se o item é uma diretoria
        then
            if [[ ! -d $backup ]]
            then                   
                if [[ "$CHECK" == false ]]       # Verifica se está no modo checking
                then
                    mkdir $backup 
                fi
                #echo "mkdir ${backup#"$(dirname $BACKUP)/"}"
            fi

            # Chama se a si própria recursivamente
            echo "BASENAME $BACKUP $(basename $item)"
            sincronizar_arquivos "$CHECK" "$EXCLUDE_LIST" "$REGEX" "$item" "$backup"
            BACKUP="${BACKUP%"$(basename $item)"}"
            echo "BASENAME2 $BACKUP"
        else
            if [ ! -e "$backup" ] || [ "$item" -nt "$backup" ]       # '-nt' = newer than
            then 
                if [[ "$CHECK" == false ]]
                then
                    cp -a "$item" "$backup}"      # Faz a copia do item preservando todos os atributos (-a)  
                fi
                #echo "cp -a $item $backup"
            fi   
        fi
    done
}

remover_arquivos_inexistentes() {

    # Procura arquivos no diretório de backup
    find "$BACKUP" -type f | while read -r arquivo; do
    
        # Manipula o valor da variável arquivo para ser o caminho correspondente na origem
        origem="$ORIGEM/${arquivo#$BACKUP/}"

        # Verifica se o arquivo correspondente na origem não existe
        if [ ! -e "$origem" ]; then
            if [[ "$CHECK" == true ]]; then  # Se estiver em modo de simulação
                echo "Simulação: rm $arquivo"  # Exibe a ação que seria tomada
            else
                rm "$arquivo"  # Remove o arquivo no backup
                echo "File deleted: $arquivo"  # Exibe a ação realizada
            fi
        fi
    done

    # Remove diretórios vazios no backup
    find "$BACKUP" -type d -empty -delete
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
    echo "$1 is not a directory"
    exit 1
fi

# Verifica se o backup não é uma diretoria e consequencialmente se não existe
if [ ! -d "$BACKUP" ]
then
    if [[ "$CHECK" == false ]]
    then
        mkdir -p "$BACKUP"      # Cria a diretoria. Caso as diretorias 'acima' não existam, estas serão criadas também
    fi
    echo "mkdir ${BACKUP#*/}"
fi

# Verifica as permissões (escrita no backup e leitura na origem)
if ([ ! -w "$BACKUP" ] || [ ! -r "$ORIGEM" ]) && [[ $CHECK == false ]]
then
    echo "Check the writing permissions on the backup directory or the reading permissions from the source"
    exit 2
fi


sincronizar_arquivos "$CHECK" "$EXCLUDE_LIST" "$REGEX" "$ORIGEM" "$BACKUP"
#if [[ -e "$BACKUP" ]]
#then
    #remover_arquivos_inexistentes
#fi

