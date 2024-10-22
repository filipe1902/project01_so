#!/bin/bash

sincronizar_arquivos() {

    # Procura apenas ficheiros na origem / O input introduzido no read sera o output do find e será guardado na variavel arquivo
    find "$ORIGEM" -maxdepth 1 -type f | while read -r arquivo      
    do  
        # Manipula o valor da variavel arquivo para ser o caminho do backup
        backup="$BACKUP/${arquivo#$ORIGEM}"         # Usamos parametros de expansao para trocar o caminho do arquivo pelo caminho do backup

        # Verifica se o ficheiro existe ou o arquivo é mais recente que o backup
        if [ ! -e "$backup" ] || [ "$arquivo" -nt "$backup" ]       # '-nt' = newer than
        then    
            if [[ "$CHECK" == false ]]
            then
                cp -a "$arquivo" "$backup"      # Faz a copia do arquivo preservando todos os atributos (-a)  
            fi
            echo "cp -a $arquivo $backup"
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
            if [[ "$CHECK" == false ]]; then  # Se estiver em modo de simulação
                rm "$arquivo"  # Remove o arquivo no backup
            fi
            echo "m "$arquivo""  # Exibe a ação realizada
        fi
    done

    # Remove diretórios vazios no backup
    find "$BACKUP" -type d -empty -delete
}

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
elif [[ $# -eq 3 ]] && [[ "$1" != "-c" ]]
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
    if [[ "$CHECK" == false ]]
    then
        mkdir -p "$BACKUP"      # Cria a diretoria. Caso as diretorias 'acima' não existam, estas serão criadas também
    fi
    echo "mkdir -p $BACKUP"
fi

sincronizar_arquivos
remover_arquivos_inexistentes

# Verifica as permissões (escrita no backup e leitura na origem)
if [ ! -w "$BACKUP" ] || [ ! -r "$ORIGEM" ]
then
    echo "Check the writing permissions on the backup directory or the reading permissions from the source"
    exit 2
fi


#sincronizar_arquivos
#remover_arquivos_inexistentes

echo "Backup done!"
