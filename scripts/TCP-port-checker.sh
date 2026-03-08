#!/bin/bash

# ==========================================================
# SCRIPT: Verificação de Portas TCP em Hosts de Rede
#
# Objetivo:
#   Testar múltiplas portas TCP em uma lista de hosts,
#   identificando serviços acessíveis e registrando os
#   resultados em arquivo de log.
#
# Cenário:
#   Utilizado para:
#   - Validação rápida de serviços ativos (SSH, HTTP, HTTPS, DNS)
#   - Auditoria básica de exposição de portas
#   - Diagnóstico de indisponibilidade de serviços
#   - Testes iniciais antes de troubleshooting avançado
#
# Funcionamento:
#   - Verifica existência do arquivo de hosts
#   - Define lista de portas TCP a serem testadas
#   - Executa teste de conexão via netcat (nc)
#   - Identifica portas ABERTAS ou FECHADAS
#   - Registra resultados em log diário
#
# Diferencial Técnico:
#   - Uso de array para múltiplas portas
#   - Timeout configurável de conexão
#   - Teste silencioso utilizando nc -z
#   - Estrutura compatível com automação e auditoria
#
# Autor: Francklin Leandro
# Data: 13/02/2026
#
# Requisitos:
#   - bash
#   - nc (netcat)
#
# Arquivo de Entrada:
#   $HOME/rede/lista_hosts.txt
#
# Diretório de Logs:
#   $HOME/rede/logs
#
# Uso:
#   ./TCP-port-checker.sh
# ==========================================================

# Arquivo com lista de hosts (um por linha)
ARQUIVO_HOSTS="$HOME/rede/lista_hosts.txt"

# Lista de portas TCP a serem testadas
PORTAS_TCP=(22 80 443 53)

# Timeout de conexão (em segundos)
TIMEOUT=3

# Diretório e arquivo de log
DIRETORIO_LOG="$HOME/rede/logs"
DATA_ATUAL="$(date +%d-%m-%Y)"
ARQUIVO_LOG="$DIRETORIO_LOG/portas_$DATA_ATUAL.log"

# Verifica se o arquivo de hosts existe
if [ ! -f "$ARQUIVO_HOSTS" ]; then
  echo "ERRO: Arquivo $ARQUIVO_HOSTS não encontrado."
  exit 1
fi

# Cria o diretório de logs se não existir
mkdir -p "$DIRETORIO_LOG"

echo "=================================================="
echo " VERIFICAÇÃO DE PORTAS TCP EM HOSTS DE REDE"
echo " Data: $(date)"
echo "=================================================="
echo | tee -a "$ARQUIVO_LOG"

# Leitura de cada host do arquivo
while read -r HOST; do

  # Ignora linhas vazias ou comentadas
  [[ -z "$HOST" || "$HOST" =~ ^# ]] && continue

  echo "Host: $HOST" | tee -a "$ARQUIVO_LOG"

  # Testa cada porta definida
  for PORTA in "${PORTAS_TCP[@]}"; do

    # Realiza um teste de conexão TCP para verificar se uma porta específica está aberta em um host
    # nc: Executa o Netcat, ferramenta de leitura/escrita em conexões de rede
    # -z: Modo scan: não envia dados, apenas testa se a conexão é possível
    # -w $TIMEOUT: Define o tempo máximo de espera (em segundos) pela resposta
    # $HOST: IP ou hostname de destino
    # $PORTA: Porta TCP a ser testada
    if nc -z -w "$TIMEOUT" "$HOST" "$PORTA" &> /dev/null; then
      echo "  Porta $PORTA/TCP: ABERTA" | tee -a "$ARQUIVO_LOG"
    else
      echo "  Porta $PORTA/TCP: FECHADA ou INACESSÍVEL" | tee -a "$ARQUIVO_LOG"
    fi

  done

  echo "--------------------------------------------------" | tee -a "$ARQUIVO_LOG"

done < "$ARQUIVO_HOSTS"

echo
echo "Verificação concluída."
echo "Log salvo em: $ARQUIVO_LOG"

exit 0
