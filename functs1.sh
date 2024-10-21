#!/bin/bash

sincronizar_arquivos() {

    local CHECK=$1          # Atribui o primeiro argumento passado à função a uma variavel local 
    
    echo "Sincronizing new files and modified ones..."

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

    local CHECK=$1

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