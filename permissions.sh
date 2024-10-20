#!/bin/bash

# Função para verificar permissões
verificar_permissoes() {
    permissao_ok=true

    if [ ! -r "$ORIGEM" ]; then
        echo "Permissão de leitura negada para a diretoria de origem: '$ORIGEM'."
        permissao_ok=false
    fi

    if [ ! -w "$BACKUP" ]; then
        echo "Permissão de escrita negada para a diretoria de backup: '$BACKUP'."
        permissao_ok=false
    fi

    # Se não houver problema de permissões, retorne verdadeiro
    if [ "$permissao_ok" = true ]; then
        return 0
    else
        return 1
    fi
}

# Função para alterar permissões
corrigir_permissoes() {
    if [ ! -r "$ORIGEM" ]; then
        echo "Alterando permissões de leitura para a diretoria de origem: '$ORIGEM'."
        chmod +r "$ORIGEM"
    fi

    if [ ! -w "$BACKUP" ]; then
        echo "Alterando permissões de escrita para a diretoria de backup: '$BACKUP'."
        chmod +w "$BACKUP"
    fi
}

# Verifica se o script recebeu os diretórios de origem e destino como parâmetros
if [ "$#" -ne 2 ]; then
    echo "Uso: $0 <diretoria_origem> <diretoria_backup>"
    exit 1
fi

# Diretoria de origem e backup
ORIGEM="$1"
BACKUP="$2"

# Verifica se há permissões corretas
if ! verificar_permissoes; then
    echo "Há problemas de permissões."

    # Pergunta ao usuário se ele deseja corrigir as permissões
    read -p "Deseja alterar as permissões automaticamente? (s/n): " resposta

    if [[ "$resposta" =~ ^[sS]$ ]]; then
        # Se o usuário aceitar, corrigir as permissões
        corrigir_permissoes

        # Verificar permissões novamente após a correção
        if ! verificar_permissoes; then
            echo "As permissões ainda não estão corretas. Verifique manualmente."
            exit 2
        fi
    else
        echo "Por favor, ajuste as permissões e execute o script novamente."
        exit 2
    fi
fi

# Se tudo estiver OK, continue com o resto do script
echo "Permissões corretas. Continuando com o backup..."

# Coloque aqui o restante do código de backup