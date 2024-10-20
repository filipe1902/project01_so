#!/bin/bash


sincronizar_arquivos() {

    echo "A sincronizar novos arquivos e arquivos modificados..."

    # Procura apenas ficheiros na origem / O input introduzido no read sera o output do find e será guardado na variavel arquivo
    find "$ORIGEM" -type f | while read -r arquivo      
    do  
        # Manipula o valor da variavel arquivo para ser o caminho do backup
        backup="$BACKUP/${arquivo#$ORIGEM}"         # Usamos parametros de expansao para trocar o caminho do arquivo pelo caminho do backup

        # Verifica se o ficheiro existe ou o arquivo é mais recente que o backup
        if [ ! -e "$backup" ] || [ "$arquivo" -nt "$backup" ]       # '-nt' = newer than
        then    
            mkdir -p $(dirname $backup)     # dirname e um comando que estrai o caminho da diretoria do ficheiro destino
            cp -a "$arquivo" "$backup"      # faz a copia do arquivo preservando todos os atributos (-a)  
            echo "Arquivo $arquivo atualizado."
        fi
    done
}

remover_arquivos_inexistentes() { #objetivo: remover arquivos e diretórios que já não existem na origem, mas ainda estão presentes no diretório de backup

    echo "A remover arquivos e diretórias inexistentes..."

    find "$BACKUP" -type f | while read -r arquivo
    do
        origem="$ORIGEM/${arquivo#BACKUP}"
        
        if [ ! -e "$origem" ]       # Verifica se o arquivo origem existe no arquivo backup
        then                        # Caso não exista, irá eliminá-lo da do backup tambem
            rm "$arquivo"
            echo "Arquivo eliminado: $arquivo"
        fi
    done

    find "$BACKUP" -type d -empty -delete    

}