#!/bin/bash

# ==========================================================
# SCRIPT: Teste de Conectividade (Ping) de Switches em Lote
#
# Objetivo:
#   Verificar a disponibilidade (UP/DOWN) de múltiplos switches
#   listados em arquivos CSV, gerando relatório consolidado em log.
#
# Cenário:
#   Utilizado em ambientes corporativos para:
#   - Verificação rápida de disponibilidade de switches por site
#   - Validação de falhas após quedas de energia
#   - Checagem matinal de infraestrutura
#   - Apoio a troubleshooting de indisponibilidade
#
# Funcionamento:
#   - Lê todos os arquivos .csv de um diretório específico
#   - Ignora linhas vazias ou comentadas (#)
#   - Extrai NOME, IP, SITE e MODELO
#   - Executa ping com 2 tentativas e timeout de 2 segundos
#   - Classifica o switch como UP ou DOWN
#   - Gera log diário formatado
#
# Autor: Francklin Leandro
# Data: 13/02/2026
#
# Requisitos:
#   - bash
#   - ping
#
# Diretório de Entrada:
#   $HOME/PINGS/ARQUIVOS_SWITCH/
#
# Diretório de Log:
#   $HOME/PINGS/LOG_SWITCH/
#
# Saída:
#   Relatório no formato:
#   NOME; IP; SITE; MODELO; STATUS
#
# Uso:
#   ./switch-csv.sh
# ==========================================================

shopt -s nullglob
# Ativa a opção nullglob para padrões que não encontrem arquivos
# Resultem em uma lista vazia, evitando erros caso não existam arquivos CSV

DIRETORIO_SWITCHES="$HOME/PINGS/ARQUIVOS_SWITCH" 
# Define o diretório onde estão armazenados os arquivos CSV dos switches
ARQUIVOS_SWITCHES=("$DIRETORIO_SWITCHES"/*.csv) 
# Cria um array contendo todos os arquivos .csv encontrados no diretório definido

LOG="$HOME/PINGS/LOG_SWITCH/switch_$(date +%d-%m-%Y).log"

echo -e "\n------ DATA: $(date +%d-%m-%Y) ------" | tee "$LOG" # Escreve no arquivo de log (sobrescrevendo o arquivo)
echo -e "\nNOME; IP; SITE; MODELO; STATUS" | tee -a "$LOG"
echo -e "\n------ INICIANDO TESTE DE PING DOS SWITCHES ------" | tee -a "$LOG"
echo "" | tee -a "$LOG"
# Escreve no arquivo de log (sem sobrescrever)

for ARQUIVO in "${ARQUIVOS_SWITCHES[@]}"; do # Percorre cada arquivo CSV encontrado no array de arquivos de switches

    [ ! -f "$ARQUIVO" ] && continue
    # Verifica se o item realmente é um arquivo regular
    # Caso não seja, pula para o próximo arquivo

    readarray -t LINHAS < "$ARQUIVO"

    for linha in "${LINHAS[@]}"; do

        [ -z "$linha" ] || [[ "$linha" == \#* ]] && continue # Ignora linhas vazias ou linhas que começam com # (comentários)

        IFS=";" read -r NOME IP SITE MODELO <<< "$linha"
        # Divide a linha usando ';' como separador e atribui os valores
        # às variáveis NOME, IP, SITE e MODELO

        ping -c 2 -W 2 "$IP" > /dev/null 2>&1 # Envia dois pacotes para cada IP. Cada um aguarda 2 segundos

        # Verifica se o último comando(ping) foi executado com sucesso
        if [ $? -eq 0 ]; then
            STATUS="UP"
        else
            STATUS="DOWN"
        fi

        echo "$NOME; $IP; $SITE; $MODELO; $STATUS" | tee -a "$LOG"
        echo "" | tee -a "$LOG"

    done
done

echo -e "\n------ TESTE FINALIZADO ------" | tee -a "$LOG"
