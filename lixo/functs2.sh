#!/bin/bash

sincronizar_arquivos() {

    local CHECK=$1          # Atribui o primeiro argumento passado à função a uma variavel local
    local DELETE_LIST=$2 
    local REGEX=$3
    local ORIGEM=$4
    local BACKUP=$5
    
    echo "Sincronizing new files and modified ones..."

    # Procura apenas ficheiros na origem / O input introduzido no read sera o output do find e será guardado na variavel item
    find "$ORIGEM" -type d -o -type f | while read -r item      
    do  
        # Manipula o valor da variavel item para ser o caminho do backup
        backup="$BACKUP/${item#$ORIGEM}"         # Usamos parametros de expansao para trocar o caminho do item pelo caminho do backup

        # Verifica se o ficheiro existe ou o item é mais recente que o backup
        if [[ -d "$item" ]]      # Verifica se o item é uma diretoria
        then                        
            if [[ "$CHECK" == true ]]       # Verifica se está no modo checking
            then
                echo "mkdir -p $backup"
            else    
                mkdir -p $backup
                echo "mkdir -p $backup"
                echo "Directory created: $backup"
            fi

            # Chama se a si própria recursivamente
            ./backup.sh ${CHECK:+-c} ${DELETE_LIST:+-b "$DELETE_LIST"} ${REGEX:+-r "$REGEX"} "$item" "$backup"
        else
            if [ ! -e "$backup" ] || [ "$item" -nt "$backup" ]       # '-nt' = newer than
            then 
                if [[ "$CHECK" == true ]]
                then
                    echo "cp -a $arquivo $backup"            
                else
                    cp -a "$arquivo" "$backup"      # Faz a copia do arquivo preservando todos os atributos (-a)  
                    echo "cp -a $arquivo $backup"

                    echo "File $arquivo updated."
                fi
            fi   
        fi
    done
}

remover_arquivos_inexistentes() {

    local CHECK=$1

    echo "Removing non-existing files..."

    find "$BACKUP" -maxdepth 1 -type f | while read -r arquivo
    do
        origem="$ORIGEM/${arquivo#BACKUP}"
        
        if [ ! -e "$origem" ]       # Verifica se o arquivo origem existe no arquivo backup
        then                        # Caso não exista, irá eliminá-lo da do backup tambem
            if [[ "$CHECK" == true ]]
            then
                echo "rm $arquivo"
            else
                rm "$arquivo"
                echo "rm $arquivo"
                echo "File deleted: $arquivo"
            fi
        fi
    done 
}