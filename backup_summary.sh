#!/bin/bash

error_count=0
warning_count=0
update_count=0
copy_count=0
delete_count=0
copied_size=0
deleted_size=0

usage() {
    echo "Usage: $0 [-c] [-b tfile] [-r regexpr] <source_directory> <backup_directory>"
    exit 1
}

exibir_warnings() {
    local dir_path="$1"
    local relative_path="${dir_path#"$ORIGEMOG"}"  # Remove o prefixo da origem
    echo "While backuping ${relative_path#/}: $error_count Errors; $warning_count Warnings; $update_count Updated; $copy_count Copied ($copied_size B); $delete_count Deleted ($deleted_size B)"
    echo ""
}

verificar_condicoes() {
    # Verificar se o diretório origem existe
    if [ ! -d "$ORIGEMOG" ]; then
        echo "Error: Source directory '$ORIGEMOG' does not exist."
        ((error_count++))
    fi

    # Verificar se o diretório de backup é válido
    if [ ! -d "$BACKUPOG" ]; then
        echo "Error: Backup directory '$BACKUPOG' does not exist. Creating it."
        if [[ "$CHECK" == false ]]; then
            mkdir -p "$BACKUPOG"
            if [ $? -ne 0 ]; then
                echo "Error: Failed to create backup directory '$BACKUPOG'."
                ((error_count++))
            fi
        else
            ((error_count++))
        fi
    fi

    # Verificar permissões de escrita no backup
    if [ ! -w "$BACKUPOG" ]; then
        echo "Error: No write permission for backup directory '$BACKUPOG'."
        ((error_count++))
    fi

    # Verificar permissões de leitura na origem
    if [ ! -r "$ORIGEMOG" ]; then
        echo "Error: No read permission for source directory '$ORIGEMOG'."
        ((error_count++))
    fi

    # Verificar se a lista de exclusão existe, se especificada
    if [[ -n "$EXCLUDE_LIST" && ! -f "$EXCLUDE_LIST" ]]; then
        echo "Error: Exclude list file '$EXCLUDE_LIST' does not exist."
        ((error_count++))
    fi

    # Verificar se há erros no final das verificações
    if [[ $error_count -gt 0 ]]; then
        echo "Total errors detected: $error_count. Exiting."
        exit 1
    fi
}


sincronizar_arquivos() {
    local CHECK="$1"
    local EXCLUDE_LIST="$2"
    local REGEX="$3"
    local ORIGEM="$4"
    local BACKUP="$5"

    local error_count=0
    local warning_count=0
    local update_count=0
    local copy_count=0
    local delete_count=0
    local copied_size=0
    local deleted_size=0

    for item in "$ORIGEM"/*; do
        nome_item=$(basename "$item")
        backup="$BACKUP${item#$ORIGEM}"

        if [[ "$item" == "$ORIGEM" ]]; then
            continue
        fi

        for exclude in "${excluded_files[@]}"; do
            if [[ "$exclude" == "$nome_item" ]]; then
                continue 2
            fi
        done

        if [[ -n "$REGEX" ]] && ! echo "$nome_item" | grep -qE "$REGEX"; then
            continue
        fi

        if [[ -d "$item" ]]; then
            if [[ ! -d "$backup" ]]; then
                if [[ "$CHECK" == false ]]; then
                    mkdir "$backup"
                fi
                echo "mkdir ${backup#"$(dirname $BACKUPOG)/"}"
            fi
            sincronizar_arquivos "$CHECK" "$EXCLUDE_LIST" "$REGEX" "$item" "$backup"
            
        elif [[ -f "$item" ]]; then
            if [[ -e "$backup" ]] && [[ "$backup" -nt "$item" ]]; then
                echo "WARNING: backup entry $backup is newer than $item; Should not happen"
                ((warning_count++))
            fi

            if [[ ! -e "$backup" ]] || [[ "$item" -nt "$backup" ]]; then
                if [[ ! -e "$backup" ]]; then
                    ((copy_count++))
                else
                    ((update_count++))
                fi
                file_size=$(stat -c%s "$item")
                if [[ "$CHECK" == false ]]; then
                    cp -a "$item" "$backup"
                fi
                echo "cp -a ${item#"$(dirname $ORIGEMOG)/"} ${backup#"$(dirname $BACKUPOG)/"}"

                copied_size=$((copied_size + file_size))
            fi
        fi
    done

    exibir_warnings "$ORIGEM"
}

remover_arquivos_inexistentes() {
    local CHECK="$1"
    local ORIGEM="$2"
    local BACKUP="$3"

    local error_count=0
    local warning_count=0
    local update_count=0
    local copy_count=0
    local delete_count=0
    local copied_size=0
    local deleted_size=0


    for item in "$BACKUP"/*; do
        origem="$ORIGEM/${item#$BACKUP/}"

        if [[ -d "$item" ]]; then
            if [[ ! -d "$origem" ]]; then
                if [[ "$CHECK" == false ]]; then
                    rm -rf "$item"
                fi
                echo "rm -rf ${item#"$(dirname $BACKUPOG)/"}"
                ((delete_count++))
                deleted_size=$((deleted_size + $(du -sb "$item" | cut -f1)))  # Soma o tamanho da diretoria
                #exibir_warnings "$ORIGEM"
                continue
            fi

            remover_arquivos_inexistentes "$CHECK" "$origem" "$item"

        elif [[ -f "$item" ]]; then
            if [[ ! -f "$origem" ]]; then
                file_size=$(stat -c%s "$item")
                if [[ "$CHECK" == false ]]; then
                    rm "$item"
                fi
                #echo "rm ${item#"$(dirname $BACKUPOG)/"}"
                ((delete_count++))
                deleted_size=$((deleted_size + file_size))
            fi
        fi
    done
    
    if [[ delete_count -gt 0 ]]; then
        local base_dir=$(dirname "$BACKUPOG")
        local relative_backup="${BACKUP#$base_dir/}"
        exibir_warnings "$relative_backup"
    fi
}

CHECK=false
EXCLUDE_LIST=""
REGEX=""
excluded_files=()

while getopts ":cb:r:" opt; do
    case "$opt" in
        c) CHECK=true ;;
        b) EXCLUDE_LIST="$OPTARG" ;;
        r) REGEX="$OPTARG" ;;
        *) usage ;;
    esac
done

shift $((OPTIND - 1))

if [ $# -ne 2 ]; then
    usage
fi

ORIGEMOG="$1"
BACKUPOG="$2"

if [ ! -d "$ORIGEMOG" ]; then
    echo "$1 is not a directory"
    exit 1
fi

if [ ! -d "$BACKUPOG" ]; then
    if [[ "$CHECK" == false ]]; then
        mkdir -p "$BACKUPOG"
    fi
    echo "mkdir ${BACKUPOG#"$(dirname $BACKUPOG)/"}"
fi

if ([ ! -w "$BACKUPOG" ] || [ ! -r "$ORIGEMOG" ]) && [[ $CHECK == false ]]; then
    echo "Check the writing permissions on the backup directory or the reading permissions from the source"
    exit 2
fi

if [[ -n "$EXCLUDE_LIST" ]]; then
    while IFS= read -r line; do
        excluded_files+=("$line")
    done < "$EXCLUDE_LIST"
fi

sincronizar_arquivos "$CHECK" "$EXCLUDE_LIST" "$REGEX" "$ORIGEMOG" "$BACKUPOG"
if [[ -e "$BACKUPOG" ]]; then
    remover_arquivos_inexistentes "$CHECK" "$ORIGEMOG" "$BACKUPOG"
fi
