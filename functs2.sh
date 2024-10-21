#!/bin/bash

# Função para sincronizar arquivos e diretórios de forma recursiva
sincronizar_arquivos() {

    local source_dir="$1"   # diretório de origem como primeiro arg
    local backup_dir="$2"   # diretório de backup como segundo arg
    local check="$3"        # flag de simulacao como terceiro arg

    # itera sobre todos os itens (arquivos e diretórios) no diretório de origem
    for item in "$source_dir"/*; do
    
        local item_name=$(basename "$item") # obtém o nome do item (arquivo ou diretório)
        local backup_item="$backup_dir/$item_name"  # define o caminho correspondente no diretório de backup

        if [ -d "$item" ]; then  # se o item for um diretório
            if [ ! -d "$backup_item" ]; then    # se o diretório correspondente no backup não existir
                if [[ "$check" == true ]]; then # e se estiver em modo de simulacao
                    echo "Simulação: mkdir -p $backup_item" # exibe a acao que seria tomada
                else
                    mkdir -p "$backup_item" && echo "mkdir -p $backup_item" # cria o diretório no backup e exibe a acao
                fi
            fi

            sincronizar_arquivos "$item" "$backup_item" "$check"    # chama a função recursivamente para sincronizar o conteúdo do subdiretório
        elif [ -f "$item" ]; then  # se o item for um arquivo
            if [ ! -f "$backup_item" ] || [ "$item" -nt "$backup_item" ]; then  # se o arquivo correspondente no backup não existir ou se o arquivo de origem for mais recente
                if [[ "$check" == true ]]; then # se estiver em modo de simulacao
                    echo "Simulação: cp -a $item $backup_item"  # exibe a acao que seria tomada
                else
                    cp -a "$item" "$backup_item" && echo "cp -a $item $backup_item" # copia o arquivo para backup e exibe a acao
                fi
            fi
        fi
    done
}


# Função para remover arquivos e diretórios que não existem mais na origem
remover_arquivos_inexistentes() {

    local source_dir="$1"   # diretório de origem como 1 arg
    local backup_dir="$2"   # diretório de backup como 2 arg
    local check="$3"        # flag de simulacao como 3 arg

    # itera sobre todos os itens (arquivos e diretorios) no diretório de backup
    for backup_item in "$backup_dir"/*; do 
        local item_name=$(basename "$backup_item") # obtém o nome do item (arquivo ou diretório)
        local source_item="$source_dir/$item_name"  # defini caminho correspondente no diretório de origem

        if [ -d "$backup_item" ]; then  # se o item for um diretório
            if [ ! -d "$source_item" ]; then    # se o diretório correspondente na origem não existir
                if [[ "$check" == true ]]; then # se estiver em modo simulacao
                    echo "Simulação: rm -r $backup_item"    # exibe a acao que seria executada
                else
                    rm -r "$backup_item" && echo "rm -r $backup_item"   #remove o diretório no backup e exibe a acao
                fi
            else
                # chama a função recursivamente para verificar o conteúdo do subdiretório
                remover_arquivos_inexistentes "$source_item" "$backup_item" "$check"
            fi
        elif [ -f "$backup_item" ]; then  # se o item for um arquivo
            if [ ! -f "$source_item" ]; then    # se o arquivo correspondente na origem não existir 
                if [[ "$check" == true ]]; then # se estiver em modo de simulacao
                    echo "Simulação: rm $backup_item"   # exibe a acao que seria tomada
                else
                    rm "$backup_item" && echo "rm $backup_item" # remove o arquivo no backup e exibe a acao
                fi
            fi
        fi
    done
}
