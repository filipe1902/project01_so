#!/bin/bash

sincronizar_arquivos() {

    local CHECK=$1

    echo "Sincronizing new files and modified ones..."

    # Procura apenas ficheiros na origem / O input introduzido no read sera o output do find e será guardado na variavel arquivo
    find "$ORIGEM" -maxdepth 1 -type f | while read -r arquivo      
    do  
        # Manipula o valor da variavel arquivo para ser o caminho do backup
        backup="$BACKUP/${arquivo#$ORIGEM}"         # Usamos parametros de expansao para trocar o caminho do arquivo pelo caminho do backup

        # Verifica se o ficheiro existe ou o arquivo é mais recente que o backup
        if [ ! -e "$backup" ] || [ "$arquivo" -nt "$backup" ]       # '-nt' = newer than
        then    
            if [[ "$CHECK" == true ]]
            then
                echo "cp -a $arquivo $backup"            
            else
                cp -a "$arquivo" "$backup"      # faz a copia do arquivo preservando todos os atributos (-a)  
                echo "cp -a $arquivo $backup"

                echo "File $arquivo updated."
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