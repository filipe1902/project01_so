#!/bin/bash

sincronizar_arquivos() {

    # Loop para iterar sobre cada arquivo na diretoria origem - sem find
    for arquivo in "$ORIGEMOG"/*; do
        # Verifica se é um arquivo regular
        if [ -f "$arquivo" ]; then
            # Manipula o valor da variável arquivo para ser o caminho do backup
            backup="$BACKUPOG/${arquivo#$ORIGEMOG}"

            # Verifica se o arquivo não existe no backup ou se é mais recente que o backup
            if [ ! -e "$backup" ] || [ "$arquivo" -nt "$backup" ]; then
                if [[ "$CHECK" == false ]]; then
                    cp -a "$arquivo" "$backup"  # Faz a cópia do arquivo preservando todos os atributos (-a)
                fi
                echo "cp -a ${arquivo#"$(dirname "$ORIGEMOG")/"} ${backup#"$(dirname "$BACKUPOG")/"}"
            fi
        fi
    done
}

remover_arquivos_inexistentes() {

    # Loop para iterar sobre cada arquivo no diretório de backup (sem usar o find)
    for arquivo in "$BACKUPOG"/*; do
        # Verifica se é um arquivo regular
        if [ -f "$arquivo" ]; then
            # Manipula o valor da variável arquivo para ser o caminho correspondente na origem
            origem="$ORIGEMOG/${arquivo#$BACKUPOG}"

            # Verifica se o arquivo correspondente na origem não existe
            if [ ! -e "$origem" ]; then
                if [[ "$CHECK" == false ]]; then
                    rm "$arquivo"  # Remove o arquivo no backup
                fi
                echo "rm ${arquivo#"$(dirname "$BACKUPOG")/"}"
            fi
        fi
    done

    # Remove diretórios vazios no backup
    for dir in "$BACKUPOG"/*; do
        if [ -d "$dir" ] && [ -z "$(ls -A "$dir")" ]; then
            rmdir "$dir"  # Remove diretório vazio
            echo "Removed empty directory: ${dir#"$(dirname "$BACKUPOG")/"}"
        fi
    done
}

# Verifica se o utilizador introduziu menos de dois ou mais que três argumentos
if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    echo "Usage: $0 [-c] <source.directory> <backup.directory>"
    exit 1
fi

# Verifica se, para três argumentos, o primeiro argumento é '-c'
CHECK=false  # Check vai ser o valor booleano que indica se o utilizador pretende fazer "checking" do backup
if [[ $# -eq 3 ]] && [[ "$1" == "-c" ]]; then
    CHECK=true
    ORIGEMOG="$2"
    BACKUPOG="$3"

# Caso o primeiro argumento não seja '-c', sai do programa
elif [[ $# -eq 3 ]] && [[ "$1" != "-c" ]]; then
    echo "Usage: $0 [-c] <source.directory> <backup.directory>"
    exit 1

# Caso só tenha dois argumentos:
else
    ORIGEMOG="$1"
    BACKUPOG="$2"
fi

# Verifica se a origem não é uma diretoria e, consequentemente, se não existe
if [ ! -d "$ORIGEMOG" ]; then
    exit 1
fi

# Verifica se o backup não é uma diretoria e, consequentemente, se não existe
if [ ! -d "$BACKUPOG" ]; then
    if [[ "$CHECK" == false ]]; then
        mkdir -p "$BACKUPOG"  # Cria a diretoria. Caso as diretorias 'acima' não existam, estas serão criadas também
    fi
    echo "mkdir -p ${BACKUPOG#"$(dirname "$BACKUPOG")/"}"
fi

# Verifica as permissões (escrita no backup e leitura na origem)
if ([ ! -w "$BACKUPOG" ] || [ ! -r "$ORIGEMOG" ]) && [[ $CHECK == false ]]; then
    exit 2
fi

sincronizar_arquivos

# Verifica se o backup existe
if [[ -d "$BACKUPOG" ]]; then
    remover_arquivos_inexistentes
fi
