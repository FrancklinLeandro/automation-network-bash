#!/bin/bash

# ==========================================================
# SCRIPT: Monitoramento de Tráfego de Rede (RX/TX)
#
# Objetivo:
#   Monitorar o volume de tráfego de uma interface de rede,
#   calculando taxa de recebimento (RX) e transmissão (TX)
#   em KB/s durante um período determinado.
#
# Cenário:
#   Utilizado para:
#   - Análise de consumo de banda
#   - Diagnóstico de lentidão de rede
#   - Monitoramento básico de throughput
#   - Verificação de picos de tráfego
#
# Funcionamento:
#   - Define interface de rede a ser monitorada
#   - Valida existência da interface
#   - Coleta bytes RX e TX em /proc/net/dev
#   - Calcula diferença entre amostras
#   - Converte valores para KB/s
#   - Registra todas as medições em log
#
# Diferencial Técnico:
#   - Leitura direta do /proc/net/dev (baixo overhead)
#   - Cálculo manual de throughput por intervalo
#   - Controle configurável de intervalo e amostras
#   - Geração de log com timestamp completo
#
# Autor: Francklin Leandro
# Data: 13/02/2026
#
# Requisitos:
#   - bash
#   - awk
#   - ip (iproute2)
#
# Interface Configurada:
#   ens160
#
# Diretório de Logs:
#   $HOME/rede/logs
#
# Uso:
#   ./bandwidth-usage-monitor.sh
# ==========================================================

# Interface de rede a ser monitorada
INTERFACE_REDE="xxxx"

# Intervalo entre coletas (em segundos)
INTERVALO=5

# Número de amostras
# São a quantidade de medições periódicas de RX e TX da interface de rede
AMOSTRAS=10

# Diretório e arquivo de log
DIRETORIO_LOG="$HOME/rede/logs"
ARQUIVO_LOG="$DIRETORIO_LOG/trafego_${INTERFACE_REDE}_$(date +%d-%m-%Y).log"

# Cria diretório de logs se não existir
mkdir -p "$DIRETORIO_LOG"

# Verifica se a interface existe
if ! ip link show "$INTERFACE_REDE" &>/dev/null; then
  echo "Erro: interface '$INTERFACE_REDE' não encontrada."
  exit 1
fi

echo "Monitoramento de tráfego iniciado: $(date)" | tee -a "$ARQUIVO_LOG"
echo "Interface : $INTERFACE_REDE" | tee -a "$ARQUIVO_LOG"
echo "Intervalo : ${INTERVALO}s | Amostras: $AMOSTRAS" | tee -a "$ARQUIVO_LOG"
echo "--------------------------------------------------" | tee -a "$ARQUIVO_LOG"

# Função para coletar bytes RX e TX
# RX = Recebimento de dados
# TX = Transmissão de dados
coletar_trafego() {
  awk -v iface="$INTERFACE_REDE" '
    $1 ~ iface ":" {
      gsub(":", "", $1)
      print $2, $10
    }
  ' /proc/net/dev
}

# Coleta inicial
# Executa a função coletar_trafego e captura sua saída
read RX_ANT TX_ANT < <(coletar_trafego)

# Loop de monitoramento
# Este loop será executado a quantidade de vezes definida em AMOSTRAS
for ((i=1; i<=AMOSTRAS; i++)); do
  sleep "$INTERVALO"

  read RX_ATUAL TX_ATUAL < <(coletar_trafego)

  # Calcula diferença de bytes
  RX_DIFF=$((RX_ATUAL - RX_ANT))
  TX_DIFF=$((TX_ATUAL - TX_ANT))

  # Converte para KB/s
  RX_KB=$((RX_DIFF / INTERVALO / 1024))
  TX_KB=$((TX_DIFF / INTERVALO / 1024))

  echo "Amostra $i:" | tee -a "$ARQUIVO_LOG"
  echo "  RX(Dados recebidos): ${RX_KB} KB/s" | tee -a "$ARQUIVO_LOG"
  echo "  TX(Dados transmitidos): ${TX_KB} KB/s" | tee -a "$ARQUIVO_LOG"
  echo "----------------------------------------------" | tee -a "$ARQUIVO_LOG"

  RX_ANT=$RX_ATUAL
  TX_ANT=$TX_ATUAL
done

echo "Monitoramento finalizado: $(date)" | tee -a "$ARQUIVO_LOG"
