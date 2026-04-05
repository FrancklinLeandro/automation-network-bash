#!/bin/bash

# SCRIPT: Monitoramento de Conectividade em Lote (Ping)
#
# Objetivo:
#   Verificar a conectividade de múltiplos IPs ou hostnames
#   através do comando ping e registrar os resultados em log.
#
# Cenário:
#   Utilizado para:
#   - Monitoramento básico de servidores
#   - Teste rápido de conectividade de rede
#   - Verificação de disponibilidade de equipamentos
#   - Auditoria simples de infraestrutura
#
# Funcionamento:
#   - Verifica existência do arquivo de hosts
#   - Cria diretório de logs automaticamente
#   - Executa ping configurável para cada host
#   - Registra resultado (UP/DOWN) em log diário
#   - Exibe resumo final da execução
#
# Diferencial Técnico:
#   - Geração automática de log com data
#   - Uso de redirecionamento silencioso (&> /dev/null)
#   - Contadores automáticos de status
#
# Autor: Francklin Leandro
# Data: 13/02/2026
#
# Requisitos:
#   - bash
#   - ping
#
# Arquivo de Entrada:
#   $HOME/rede/lista_hosts.txt
#
# Diretório de Logs:
#   $HOME/rede/logs
#
# Uso:
#   ./host-monitor.sh
# ==========================================================

# Arquivo contendo a lista de IPs ou hostnames (um por linha)
ARQUIVO_HOSTS="$HOME/rede/lista_hosts.txt"

# Diretório onde os logs serão salvos
DIRETORIO_LOG="$HOME/rede/logs"

# Nome do arquivo de log com data
DATA_ATUAL="$(date +%Y-%m-%d)"
ARQUIVO_LOG="$DIRETORIO_LOG/ping_$DATA_ATUAL.log"

# Quantidade de pacotes enviados no ping
QTD_PING=3

# Tempo máximo de espera por resposta (em segundos)
TIMEOUT=2

# Verifica se o arquivo de hosts existe
if [ ! -f "$ARQUIVO_HOSTS" ]; then
  echo "ERRO: Arquivo $ARQUIVO_HOSTS não encontrado."
  exit 1
  # Sai do script
fi

# Cria o diretório de logs caso não exista
mkdir -p "$DIRETORIO_LOG"


echo "=============================================="
echo " INICIANDO MONITORAMENTO DE CONECTIVIDADE"
echo " Data/Hora: $(date)"
echo "=============================================="
echo ""

# Contadores para o resumo final
HOSTS_UP=0
HOSTS_DOWN=0

# Lê cada linha do arquivo de hosts
while read -r HOST; do

  # Ignora linhas vazias ou comentadas
  [[ -z "$HOST" || "$HOST" =~ ^# ]] && continue

  echo -e "\nTestando conectividade com: $HOST"

  # Executa o ping
  if ping -c "$QTD_PING" -W "$TIMEOUT" "$HOST" &> /dev/null; then
    echo "$(date '+%Y-%m-%d') - $HOST - UP" | tee -a "$ARQUIVO_LOG" # Escreve no arquivo de log (sem sobrescrever)
    ((HOSTS_UP++))
  else
    echo "$(date '+%Y-%m-%d') - $HOST - DOWN" | tee -a "$ARQUIVO_LOG"
    ((HOSTS_DOWN++))
  fi

done < "$ARQUIVO_HOSTS"

echo ""
echo "=============================================="
echo " RESUMO DO MONITORAMENTO"
echo "=============================================="
echo " Hosts com resposta : $HOSTS_UP"
echo " Hosts sem resposta : $HOSTS_DOWN"
echo " Log gerado em      : $ARQUIVO_LOG"
echo "=============================================="

exit 0
