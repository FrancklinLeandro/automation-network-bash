#!/bin/bash

# ==========================================================
# SCRIPT: Monitoramento de Concessões DHCP (Leases)
#
# Objetivo:
#   Analisar arquivos de leases DHCP gerados pelo
#   NetworkManager/dhclient e extrair informações estruturadas
#   sobre IP concedido, MAC Address, hostname e data de expiração.
#
# Cenário:
#   Utilizado para:
#   - Auditoria de dispositivos na rede
#   - Verificação de IPs concedidos via DHCP
#   - Identificação de clientes por MAC Address
#   - Análise de expiração de concessões
#
# Funcionamento:
#   - Verifica execução como root
#   - Valida existência de arquivos de lease
#   - Cria diretório de logs automaticamente
#   - Processa cada arquivo dhclient-*.lease
#   - Extrai IP, MAC, Hostname e data de expiração
#   - Registra relatório estruturado em log
#
# Diferencial Técnico:
#   - Interpretação direta do formato de lease DHCP
#   - Uso de awk para parsing estruturado
#   - Log organizado para auditoria
#
# Autor: Francklin Leandro
# Data: 13/02/2026
#
# Requisitos:
#   - bash
#   - awk
#   - Permissão root (sudo)
#
# Arquivos analisados:
#   /var/lib/NetworkManager/dhclient-*.lease
#
# Diretório de Logs:
#   $HOME/rede/logs
#
# Uso:
#   sudo ./DHCP-leases.sh
# ==========================================================

# Caminho do arquivo de leases DHCP (NetworkManager / systemd)
ARQUIVO_LEASES="/var/lib/NetworkManager/dhclient-*.lease"

# Diretório de logs
DIRETORIO_LOG="$HOME/rede/logs"

# Data para nome do log
DATA_ATUAL="$(date +%Y-%m-%d)"

# Arquivo de log
ARQUIVO_LOG="$DIRETORIO_LOG/dhcp_leases_$DATA_ATUAL.log"

# Verifica se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
  echo "ERRO: este script deve ser executado como root (sudo)."
  exit 1
fi

# Cria diretório de logs se não existir
mkdir -p "$DIRETORIO_LOG"

# Verifica se existe arquivo de leases
if ! ls $ARQUIVO_LEASES &> /dev/null; then
  echo "ERRO: Arquivo de leases DHCP não encontrado."
  exit 1
fi

echo "==================================================" | tee "$ARQUIVO_LOG"
echo " MONITORAMENTO DE CONCESSÕES DHCP (LEASES)" | tee -a "$ARQUIVO_LOG"
echo " Data: $(date)" | tee -a "$ARQUIVO_LOG"
echo "==================================================" | tee -a "$ARQUIVO_LOG"
echo | tee -a "$ARQUIVO_LOG"

# Processa cada arquivo de lease encontrado
for LEASE in $ARQUIVO_LEASES; do

  echo "Arquivo analisado: $LEASE" | tee -a "$ARQUIVO_LOG"
  echo "--------------------------------------------------" | tee -a "$ARQUIVO_LOG"

  # Extrai informações relevantes usando awk para interpretar arquivos de leases DHCP
  # e extrair informações estruturadas de cada concessão, salvando o resultado no log.
  # /lease / {ip=$2}: Detecta o início de uma concessão DHCP e captura o IP concedido;
  # /hardware ethernet/ {mac=$3}: Captura o MAC Address do cliente DHCP;
  # /client-hostname/ {host=$2}: Captura o hostname informado pelo cliente;
  # /ends/ {: Indica o fim da concessão DHCP
  # gsub: Remove ponto e vírgula, e aspas;
  # print: gera a impressão do relatório.
  awk '
    /lease / {ip=$2}
    /hardware ethernet/ {mac=$3}
    /client-hostname/ {host=$2}
    /ends/ {
      gsub(";", "", host)
      gsub("\"", "", host)
      print "IP        :", ip
      print "MAC       :", mac
      print "Hostname  :", host
      print "Expira em :", $3, $4
      print "----------------------------------------------"
    }
  ' "$LEASE" | tee -a "$ARQUIVO_LOG"

done

echo
echo "Monitoramento DHCP concluído."
echo "Log salvo em: $ARQUIVO_LOG"

exit 0
