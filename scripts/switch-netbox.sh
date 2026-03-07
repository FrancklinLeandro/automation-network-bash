#!/bin/bash

# ==========================================================
# SCRIPT: Comparação de Inventário – NetBox x Planilha CSV
#
# Objetivo:
#   Comparar dois arquivos CSV contendo switches (IP e nome)
#   para identificar inconsistências entre:
#   - Inventário oficial (NetBox)
#   - Planilha operacional/local
#
# Cenário:
#   Utilizado em ambientes corporativos para:
#   - Auditoria de inventário de switches
#   - Identificação de equipamentos não cadastrados no NetBox
#   - Detecção de dispositivos presentes no NetBox mas ausentes na planilha
#   - Apoio a governança e controle de ativos de rede
#
# Funcionamento:
#   - Lê dois arquivos CSV separados por ponto e vírgula
#   - Armazena dados em arrays associativos (IP como chave)
#   - Compara os IPs entre as duas bases
#   - Gera relatório em arquivo de log com data automática
#
# Autor: Francklin Leandro
# Data: 13/02/2026
#
# Requisitos:
#   - bash (suporte a arrays associativos)
#
# Arquivos de Entrada:
#   $HOME/PINGS/ARQUIVOS_SWITCH/IPS_SW_200_PNZ_NETBOX.csv
#   $HOME/PINGS/ARQUIVOS_SWITCH/switches_pnz.csv
#
# Diretório de Log:
#   $HOME/PINGS/LOG_SWITCH/
#
# Saída:
#   Log contendo:
#     - Switches presentes na planilha e ausentes no NetBox
#     - Switches presentes no NetBox e ausentes na planilha
#
# Uso:
#   ./switch-netbox.sh
# ==========================================================

LOG="$HOME/PINGS/LOG_SWITCH/comparacao_netbox_$(date +%d-%m-%Y).log"
# Cria o arquivo de log que contém os switches que não existem

ARQUIVO_NETBOX="$HOME/PINGS/ARQUIVOS_SWITCH/IPS_SW_200_PNZ_NETBOX.csv"
ARQUIVO_PLANILHA="$HOME/PINGS/ARQUIVOS_SWITCH/switches_pnz.csv"

declare -A NETBOX
# Cria um array associativo chamado NETBOX
# Ele será usado para armazenar os switches que existem no NetBox
# A chave do array será o IP do switch
# O valor associado à chave será o nome do switch
# Exemplo: NETBOX["10.87.200.44"]="REITORIA - DISTRIBUIÇÃO

declare -A PLANILHA
# Cria um array associativo chamado PLANILHA
# Ele será usado para armazenar os switches que existem na planilha
# Assim como no NETBOX:
# A chave será o IP do switch
# O valor será o nome correspondente
# Isso permite comparar facilmente os IPs da planilha com os IPs do NetBox

echo "------ DATA: $(date +%d-%m-%Y) ------" | tee "$LOG"
echo "------ INICIANDO COMPARAÇÃO NETBOX x PLANILHA ------" | tee -a "$LOG"
echo "" | tee -a "$LOG"

# Loop while que lê o arquivo linha por linha
# IFS=";" define o separador de campos como ponto e vírgula
# read -r evita interpretação de barras invertidas
# IP recebe o primeiro campo
# NOME recebe o segundo campo
# _ recebe o restante da linha (e é descartado)
while IFS=";" read -r IP NOME _; do
    [ -z "$IP" ] && continue
    # Se a variável IP estiver vazia, pula para a próxima linha
    # Isso evita processar linhas em branco

    NETBOX["$IP"]="$NOME"
    # Armazena no array associativo NETBOX
    # A chave é o IP
    # O valor é o nome correspondente

done < "$ARQUIVO_NETBOX"

# Loop while que lê o arquivo linha por linha
# IFS=";" define o separador de campos como ponto e vírgula
# read -r evita interpretação de barras invertidas
# NOME recebe o primeiro campo
# IP recebe o segundo campo
# _ recebe o restante da linha (e é descartado)
while IFS=";" read -r NOME IP _; do
    [ -z "$IP" ] && continue
    # Se a variável IP estiver vazia, pula para a próxima linha
    # Isso evita processar linhas em branco

    PLANILHA["$IP"]="$NOME"
    # Armazena no array associativo PLANILHA
    # A chave é o IP
    # O valor é o nome correspondente

done < "$ARQUIVO_PLANILHA"

# PLANILHA → NETBOX
echo "Switches que ESTÃO na planilha mas NÃO estão no NetBox:" | tee -a "$LOG"
echo "NOME;IP" | tee -a "$LOG"

#------------------------------------------------------------------
# "${!ARRAY[@]}" retorna todas as chaves do array associativo.
# Aqui estamos iterando sobre todos os IPs cadastrados na planilha.
# -----------------------------------------------------------------
for IP in "${!PLANILHA[@]}"; do 
    if [ -z "${NETBOX[$IP]}" ]; then 
    # Verifica se aquele IP não existe como chave no array NETBOX.
    # Se estiver vazio, significa que não foi encontrado no inventário oficial.
        echo "${PLANILHA[$IP]};$IP" | tee -a "$LOG"
    fi
done

echo "" | tee -a "$LOG"

# NETBOX → PLANILHA
echo "Switches que ESTÃO no NetBox mas NÃO estão na planilha:" | tee -a "$LOG"
echo "NOME;IP" | tee -a "$LOG"

for IP in "${!NETBOX[@]}"; do # Agora o processo é inverso: percorre todos os IPs do NetBox.
    if [ -z "${PLANILHA[$IP]}" ]; then # Verifica se o IP do NetBox não está presente na planilha operacional.
        echo "${NETBOX[$IP]};$IP" | tee -a "$LOG"
    fi
done

echo "" | tee -a "$LOG"
echo "------ COMPARAÇÃO FINALIZADA ------" | tee -a "$LOG"
