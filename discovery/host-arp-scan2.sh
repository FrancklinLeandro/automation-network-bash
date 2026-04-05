#!/bin/bash

# ==========================================================
# SCRIPT: Varredura de Rede Local via ARP (arp-scan)
#
# Objetivo:
#   Identificar dispositivos ativos na rede local
#   utilizando varredura ARP e registrar os resultados em log.
#
# Cenário:
#   Utilizado para:
#   - Descoberta de dispositivos na rede
#   - Inventário rápido de ativos
#   - Identificação de equipamentos não autorizados
#   - Auditoria básica de ambiente LAN
#
# Funcionamento:
#   - Define interface de rede
#   - Cria diretório de logs automaticamente
#   - Verifica se arp-scan está instalado
#   - Valida existência da interface de rede
#   - Executa varredura ARP na rede local
#   - Formata saída (IP, MAC e Fabricante)
#   - Registra resultados com data e hora
#
# Diferencial Técnico:
#   - Uso de awk para formatação personalizada
#   - Geração de log com timestamp completo
#   - Validações prévias de ambiente (comando e interface)
#
# Autor: Francklin Leandro
# Data: 13/02/2026
#
# Requisitos:
#   - bash
#   - arp-scan
#   - ip 
#   - Permissão sudo para execução do arp-scan
#
# Interface Configurada:
#   xxxx
#
# Diretório de Logs:
#   $HOME/rede/logs
#
# Uso:
#   sudo ./host-arp-scan2.sh
# ==========================================================

# Interface de rede a ser utilizada
INTERFACE_REDE="xxxx"

# Diretório e arquivo de log
DIRETORIO_LOG="$HOME/rede/logs"
ARQUIVO_LOG="$DIRETORIO_LOG/arp_scan_$(date +%d-%m-%Y).log"

# Cria diretório de logs se não existir
mkdir -p "$DIRETORIO_LOG"

# Verifica se o comando arp-scan está instalado
if ! command -v arp-scan &>/dev/null; then
  echo "Erro: arp-scan não está instalado."
  echo "Instale com: sudo apt install arp-scan"
  exit 1
fi

# Verifica se a interface existe
if ! ip link show "$INTERFACE_REDE" &>/dev/null; then
  echo "Erro: interface de rede '$INTERFACE_REDE' não encontrada."
  exit 1
  # Sai do script
fi

echo "Início da varredura ARP: $(date)" | tee -a "$ARQUIVO_LOG"
echo "Interface utilizada: $INTERFACE_REDE" | tee -a "$ARQUIVO_LOG"
echo "--------------------------------------------------" | tee -a "$ARQUIVO_LOG"

# Executa o arp-scan na rede local
# --localnet : usa a rede configurada na interface
# --interface: define a interface de rede
arp-scan --interface="$INTERFACE_REDE" --localnet | \

# Processa a saída do arp-scan para exibir apenas informações relevantes.
awk ' 
  /^[0-9]+\./ { 
    printf "IP        : %s\n", $1
    printf "MAC       : %s\n", $2
    printf "Fabricante: %s\n", $3
    print "----------------------------------------------"
  }
' | tee -a "$ARQUIVO_LOG"
# tee -a escreve no arquivo de log (sem sobrescrever)

echo "Varredura finalizada: $(date)" | tee -a "$ARQUIVO_LOG"
