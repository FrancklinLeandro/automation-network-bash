#!/bin/bash

# ==========================================================
# SCRIPT: Monitoramento de Access Points (APs)
#
# Objetivo:
#   Verificar a conectividade de múltiplos Access Points
#   realizando teste ICMP (ping) e registrando os resultados
#   em log estruturado.
#
# Cenário:
#   Utilizado para:
#   - Monitoramento diário de APs
#   - Verificação rápida de indisponibilidade
#   - Auditoria de conectividade Wi-Fi
#   - Controle operacional de infraestrutura wireless
#
# Funcionamento:
#   - Cria diretório de logs automaticamente
#   - Lê arquivo estruturado contendo:
#       NOME_AP HOST IP
#   - Ignora linhas vazias ou comentadas (#)
#   - Executa ping configurável por IP
#   - Registra status UP/DOWN em log
#   - Exibe resumo final da execução
#
# Diferencial Técnico:
#   - Log diário com data automática
#   - Contadores de disponibilidade
#   - Estrutura preparada para integração com planilhas
#
# Autor: Francklin Leandro
# Data: 13/02/2026
#
# Requisitos:
#   - bash
#   - ping
#
# Arquivo de Entrada:
#   $HOME/PINGS/ARQUIVOS_AP/lista_APs.txt
#
# Estrutura do Arquivo:
#   NOME_AP HOST IP
#
# Diretório de Logs:
#   $HOME/PINGS/LOG_AP
#
# Uso:
#   ./ap-scan.sh
# ==========================================================

mkdir -p "$HOME/PINGS/LOG_AP"
# Garante que o diretório de log exista

ARQUIVO_APS="$HOME/PINGS/ARQUIVOS_AP/lista_APs.txt"
# Arquivo contendo: NOME_AP HOST IP

LOG="$HOME/PINGS/LOG_AP/ap_$(date +%d-%m-%Y).log"
# Arquivo de log com data atual

# Quantidade de pacotes enviados no ping
QTD_PING=5

# Tempo máximo de espera por resposta (em segundos)
TIMEOUT=2


echo "=============================================="
echo " INICIANDO MONITORAMENTO DE CONECTIVIDADE"
echo " Data/Hora: $(date)"
echo "=============================================="
echo ""

echo "DATA; NOME_AP; HOST; IP; STATUS" | tee -a "$LOG"
echo "" | tee -a "$LOG"
# Escreve no arquivo de log (sem sobrescrever)

# Contadores para o resumo final
HOSTS_UP=0
HOSTS_DOWN=0

# Lê o arquivo linha a linha
while read -r NOME_AP HOST IP; do

    # Ignora linhas vazias ou comentadas
    [ -z "$IP" ] || [[ "$NOME_AP" == \#* ]] && continue

  # Executa o ping
  if ping -c "$QTD_PING" -W "$TIMEOUT" "$IP" &> /dev/null; then # &> /dev/null silencia tudo
    echo "$(date '+%d-%m-%Y') $NOME_AP - $HOST - $IP - UP" | tee -a "$LOG"
    ((HOSTS_UP++))
  else
    echo "$(date '+%d-%m-%Y') $NOME_AP - $HOST - $IP - DOWN" | tee -a "$LOG"
    ((HOSTS_DOWN++))
  fi

done < "$ARQUIVO_APS"

echo ""
echo "=============================================="
echo " RESUMO DO MONITORAMENTO"
echo "=============================================="
echo " Hosts com resposta : $HOSTS_UP"
echo " Hosts sem resposta : $HOSTS_DOWN"
echo " Log gerado em      : $LOG"
echo "=============================================="
