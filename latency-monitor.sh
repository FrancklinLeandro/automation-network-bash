#!/bin/bash

# ==========================================================
# SCRIPT: Monitoramento de Latência e Perda de Pacotes
#
# Objetivo:
#   Medir latência média e percentual de perda de pacotes
#   para múltiplos destinos listados em arquivo.
#
# Cenário:
#   Utilizado para:
#   - Identificar instabilidade em links WAN
#   - Monitorar qualidade de conexão com servidores críticos
#   - Coletar evidências de perda de pacotes para operadora
#   - Diagnóstico de lentidão intermitente
#
# Funcionamento:
#   - Lê destinos a partir de arquivo texto
#   - Executa ping com quantidade e intervalo configuráveis
#   - Extrai automaticamente:
#       • Percentual de perda de pacotes
#       • Latência média (avg)
#   - Registra resultados em log diário
#
# Autor: Francklin Leandro
# Data: 13/02/2026
#
# Requisitos:
#   - bash
#   - ping 
#   - grep (com suporte a -P)
#   - awk
#
# Arquivo de Entrada:
#   $HOME/rede/lista_destinos.txt
#
# Diretório de Log:
#   $HOME/rede/logs
#
# Uso:
#   1) Inserir destinos no arquivo lista_destinos.txt
#   2) Executar:
#      ./latency-monitor.sh
# ==========================================================

ARQUIVO_DESTINOS="$HOME/rede/lista_destinos.txt"
DIRETORIO_LOG="$HOME/rede/logs"
DATA_ATUAL="$(date +%Y-%m-%d)"
ARQUIVO_LOG="$DIRETORIO_LOG/latencia_$DATA_ATUAL.log"

# Quantidade de pacotes por destino
QTD_PACOTES=10

# Intervalo entre pacotes (segundos)
INTERVALO=1

# Verifica se o arquivo de destinos existe
if [ ! -f "$ARQUIVO_DESTINOS" ]; then
  echo "ERRO: Arquivo $ARQUIVO_DESTINOS não encontrado."
  exit 1
fi

# Cria diretório de logs se não existir
mkdir -p "$DIRETORIO_LOG"

echo "==================================================" | tee "$ARQUIVO_LOG"
echo " MONITORAMENTO DE LATÊNCIA E PERDA DE PACOTES" | tee -a "$ARQUIVO_LOG"
echo " Data: $(date)" | tee -a "$ARQUIVO_LOG"
echo "==================================================" | tee -a "$ARQUIVO_LOG"
echo | tee -a "$ARQUIVO_LOG"

# Leitura de cada destino
while read -r DESTINO; do

  # Ignora linhas vazias ou comentadas
  [[ -z "$DESTINO" || "$DESTINO" =~ ^# ]] && continue

  echo "Destino: $DESTINO" | tee -a "$ARQUIVO_LOG"

  # Executa o ping e captura a saída
  SAIDA_PING=$(ping -c "$QTD_PACOTES" -i "$INTERVALO" "$DESTINO" 2>/dev/null)

  # Verifica se o ping retornou algo
  if [ -z "$SAIDA_PING" ]; then
    echo "  Falha: destino inacessível" | tee -a "$ARQUIVO_LOG"
    echo | tee -a "$ARQUIVO_LOG"
    continue
  fi

  # Extrai estatísticas de perda de pacotes
  PERDA=$(echo "$SAIDA_PING" | grep -oP '\d+(?=% packet loss)')

  # Extrai latência média (avg)
  # Localiza a linha que contém "rtt" (estatísticas finais do ping).
  # Usa "/" como separador de campo.
  # O quinto campo corresponde à latência média (avg).
  LAT_MEDIA=$(echo "$SAIDA_PING" | awk -F'/' '/rtt/ {print $5}')

  echo "  Perda de pacotes : ${PERDA}%" | tee -a "$ARQUIVO_LOG"
  echo "  Latência média   : ${LAT_MEDIA} ms" | tee -a "$ARQUIVO_LOG"
  echo "--------------------------------------------------" | tee -a "$ARQUIVO_LOG"

done < "$ARQUIVO_DESTINOS"

echo
echo "Monitoramento concluído."
echo "Log salvo em: $ARQUIVO_LOG"

exit 0
