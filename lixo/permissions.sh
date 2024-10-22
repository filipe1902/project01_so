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

# Função para alterar permissões
corrigir_permissoes() {
    if [ ! -r "$ORIGEM" ]; then #Altera as permissões de leitura e escrita. Se o diretório de origem ($ORIGEM) não tiver permissão de leitura, exibe uma mensagem e usa chmod +r para adicionar a permissão de leitura
        echo "Changing read permissions for the source directory: '$ORIGEM'."
        chmod +r "$ORIGEM"
    fi

    if [ ! -w "$BACKUP" ]; then #Se o diretório de backup ($BACKUP) não tiver permissão de escrita, exibe uma mensagem e usa chmod +w para adicionar a permissão de escrita
        echo "Changing write permissions for the backup directory: '$BACKUP'."
        chmod +w "$BACKUP"
    fi
}

# Verifica se o script recebeu os diretórios de origem e destino como parâmetros
if [ "$#" -ne 2 ]; then #Verifica se o script recebeu exatamente dois parâmetros (diretoria de origem e diretoria de backup). Se não recebeu, exibe uma mensagem de uso correto e sai com código de erro 1
    echo "Usage: $0 <diretoria_origem> <diretoria_backup>"
    exit 1
fi

# Diretoria de origem e backup
ORIGEM="$1"
BACKUP="$2"

# Verifica se há permissões corretas
if ! verificar_permissoes; then
    echo "There are permission issues."

    # Pergunta ao usuário se ele deseja corrigir as permissões
    read -p "Do you want to automatically change the permissions? (y/n): " resposta

    if [[ "$resposta" =~ ^[sS]$ ]]; then
        # Se o usuário aceitar, corrigir as permissões
        corrigir_permissoes

        # Verificar permissões novamente após a correção
        if ! verificar_permissoes; then
            echo "Permissions are still not correct. Please check manually."
            exit 2
        fi
    else
        echo "Please adjust the permissions and run the script again."
        exit 2
    fi
fi

# Se tudo estiver OK, continue com o resto do script
echo "Permissions are correct. Continuing with the backup..."

# Coloque aqui o restante do código de backup