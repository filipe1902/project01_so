#!/bin/bash

verificar_permissoes() {
    permissao_certa=true

    if [ ! -r "$ORIGEM" ]; then 
        echo "Read permission denied for the source directory: '$ORIGEM'."
        permissao_certa=false
    fi

    if [ ! -w "$BACKUP" ]; then 
        echo "Write permission denied for the backup directory: '$BACKUP'."
        permissao_certa=false
    fi

    if [ "$permissao_certa" = true ]; then
        return 0
    else
        return 1
    fi
}

if [ "$#" -ne 2 ]; then 
    echo "Usage: $0 <diretoria_origem> <diretoria_backup>"
    exit 1
fi

ORIGEM="$1"
BACKUP="$2"

verificar_permissoes "$ORIGEM" "$BACKUP"
