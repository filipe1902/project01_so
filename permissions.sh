#!/bin/bash

# Função para verificar permissões
verificar_permissoes() {
    permissao_certa=true

    if [ ! -r "$ORIGEM" ]; then #Verifica se a diretório de origem ($ORIGEM) não tem permissão de leitura (-r). Se não tiver, exibe uma mensagem de erro e define permissao_certa como false
        echo "Read permission denied for the source directory: '$ORIGEM'."
        permissao_certa=false
    fi

    if [ ! -w "$BACKUP" ]; then #Verifica se o diretório de backup ($BACKUP) não tem permissão de escrita (-w). Se não tiver, exibe uma mensagem de erro e define permissao_certa como false.
        echo "Write permission denied for the backup directory: '$BACKUP'."
        permissao_certa=false
    fi

    #Se permissao_certa for true, a função retorna 0 (sucesso). Caso contrário, retorna 1 (falha).
    if [ "$permissao_certa" = true ]; then
        return 0
    else
        return 1
    fi
}

if [ "$#" -ne 2 ]; then #Verifica se o script recebeu exatamente dois parâmetros (diretoria de origem e diretoria de backup). Se não recebeu, exibe uma mensagem de uso correto e sai com código de erro 1
    echo "Usage: $0 <diretoria_origem> <diretoria_backup>"
    exit 1
fi

# Diretoria de origem e backup
ORIGEM="$1"
BACKUP="$2"

verificar_permissoes "$ORIGEM" "$BACKUP"
