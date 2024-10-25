#!/bin/bash

sincronizar_arquivos() {

    local CHECK=$1          # Atribui o primeiro argumento passado à função a uma variavel local
    local EXCLUDE_LIST=$2   # Atribui a lista de ficheiros a excluir
    local REGEX=$3          # Atribui a regex
    local ORIGEM=$4
    local BACKUP=$5
    
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

    local CHECK=$1
    local ORIGEM=$2
    local BACKUP=$3

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