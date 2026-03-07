#!/bin/bash

# ==========================================================
# SCRIPT: Diagnóstico de Rota de Rede (Traceroute em Lote)
#
# Objetivo:
#   Executar traceroute para múltiplos destinos listados
#   em um arquivo, registrando os resultados em log diário.
#
# Cenário:
#   Utilizado em ambientes corporativos ou de estágio para:
#   - Analisar caminhos de roteamento até servidores externos
#   - Identificar gargalos ou perdas de rota
#   - Registrar histórico de variações de caminho na rede
#   - Apoiar troubleshooting de lentidão ou instabilidade
#
# Funcionamento:
#   - Lê destinos a partir de um arquivo texto
#   - Ignora linhas vazias ou comentadas (#)
#   - Executa traceroute com limite configurável de saltos
#   - Gera log com data automática
#
# Autor: Francklin Leandro
# Data: 13/02/2026
#
# Requisitos:
#   - bash
#   - traceroute
#
# Arquivo de Entrada:
#   $HOME/rede/lista_destinos.txt
#
# Diretório de Logs:
#   $HOME/rede/logs
#
# Uso:
#   1) Adicionar os destinos no arquivo lista_destinos.txt
#   2) Executar:
#      ./traceroute.sh
# ==========================================================

ARQUIVO_DESTINOS="$HOME/rede/lista_destinos.txt"
DIRETORIO_LOG="$HOME/rede/logs"
DATA_ATUAL="$(date +%Y-%m-%d)"
ARQUIVO_LOG="$DIRETORIO_LOG/traceroute_$DATA_ATUAL.log"

# Número máximo de saltos
MAX_SALTOS=30

# Verifica se o traceroute está instalado
if ! command -v traceroute &> /dev/null; then
  echo "ERRO: comando 'traceroute' não encontrado."
  echo "Instale com: sudo apt install traceroute"
  exit 1
fi

# Verifica se o arquivo de destinos existe
if [ ! -f "$ARQUIVO_DESTINOS" ]; then
  echo "ERRO: Arquivo $ARQUIVO_DESTINOS não encontrado."
  exit 1
fi

# Cria diretório de logs se não existir
mkdir -p "$DIRETORIO_LOG"

echo "==================================================" | tee "$ARQUIVO_LOG"
echo " DIAGNÓSTICO DE ROTA DE REDE (TRACEROUTE)" | tee -a "$ARQUIVO_LOG"
echo " Data: $(date)" | tee -a "$ARQUIVO_LOG"
echo "==================================================" | tee -a "$ARQUIVO_LOG"
echo | tee -a "$ARQUIVO_LOG"

# Leitura de cada destino
while read -r DESTINO; do

  # Ignora linhas vazias ou comentadas
  [[ -z "$DESTINO" || "$DESTINO" =~ ^# ]] && continue

  echo "Destino: $DESTINO" | tee -a "$ARQUIVO_LOG"
  echo "--------------------------------------------------" | tee -a "$ARQUIVO_LOG"

  # Executa o traceroute, usando -m definindo o máximo de saltos
  traceroute -m "$MAX_SALTOS" "$DESTINO" | tee -a "$ARQUIVO_LOG"

  echo | tee -a "$ARQUIVO_LOG"

done < "$ARQUIVO_DESTINOS"

echo "==================================================" | tee -a "$ARQUIVO_LOG"
echo " Diagnóstico concluído." | tee -a "$ARQUIVO_LOG"
echo " Log salvo em: $ARQUIVO_LOG" | tee -a "$ARQUIVO_LOG"
echo "==================================================" | tee -a "$ARQUIVO_LOG"

exit 0
