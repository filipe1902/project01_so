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
            if [[ "$CHECK" == true ]]
            then
                echo "cp -a $arquivo $backup"            
            else
                cp -a "$arquivo" "$backup"      # Faz a copia do arquivo preservando todos os atributos (-a)  
                echo "cp -a $arquivo $backup"

                echo "File $arquivo updated."
            fi
        fi
    done
}

remover_arquivos_inexistentes() {

    local CHECK=$1  # Atribui o primeiro argumento passado à função a uma variável local

    echo "Removing non-existing files..."

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