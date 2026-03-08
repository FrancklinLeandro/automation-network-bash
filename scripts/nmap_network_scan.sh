#!/bin/bash
# ==========================================================
# SCRIPT: Varredura de Portas em Hosts de uma Rede (Nmap)
#
# Objetivo:
#   Identificar hosts ativos em uma rede e realizar varredura
#   de portas TCP comuns, detectando serviços em execução e
#   registrando os resultados em log.
#
# Cenário:
#   Utilizado para:
#   - Auditoria rápida de serviços em servidores
#   - Verificação de portas abertas em equipamentos de rede
#   - Mapeamento inicial de infraestrutura
#   - Troubleshooting de conectividade e exposição de serviços
#
# Funcionamento:
#   - Define rede alvo em notação CIDR
#   - Define lista de portas TCP comuns em ambientes corporativos
#   - Cria diretório de logs automaticamente
#   - Verifica se o Nmap está instalado
#   - Executa descoberta de hosts ativos (ping scan)
#   - Realiza varredura de portas nos hosts encontrados
#   - Identifica serviços associados às portas abertas
#   - Exibe resultados formatados no terminal
#   - Salva saída completa em log com timestamp
#
# Diferencial Técnico:
#   - Descoberta automática de hosts ativos antes do scan
#   - Uso de SYN Scan (-sS) para varredura eficiente
#   - Identificação de serviços com detecção de versão (-sV)
#   - Filtro de resultados usando awk para melhor legibilidade
#   - Geração automática de log com data e hora
#
# Autor: Francklin Leandro
# Data: 23/02/2026
#
# Requisitos:
#   - bash
#   - nmap
#
# Diretório de Logs:
#   $HOME/rede/logs
#
# Uso:
#   ./nmap_network_scan.sh
# ==========================================================

# Rede a ser escaneada
REDE_ALVO="192.168.x.x/24"
# Define a rede alvo usando notação CIDR

# Portas mais comuns em infraestrutura
PORTAS="22,23,53,80,110,123,137,139,143,161,389,443,445,3389"
# Lista de portas TCP comuns em ambientes corporativos
# SSH, Telnet, DNS, HTTP, NTP, SMB, LDAP, HTTPS, RDP etc

# Diretório e arquivo de log
DIRETORIO_LOG="$HOME/rede/logs"
# Diretório onde os logs serão armazenados

ARQUIVO_LOG="$DIRETORIO_LOG/nmap_scan_$(date +%d-%m-%Y).log"
# Cria arquivo de log com data

# Verifica se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
  echo "ERRO: este script deve ser executado como root (sudo)."
  exit 1
fi

# ----------------------------------------------------------
# Cria diretório de logs se não existir
# ----------------------------------------------------------
mkdir -p "$DIRETORIO_LOG"
# -p cria diretórios recursivamente e não gera erro se já existir

# ----------------------------------------------------------
# Verifica se o nmap está instalado
# ----------------------------------------------------------
if ! command -v nmap &>/dev/null; then
# command -v verifica se o comando existe no PATH

  echo "ERRO: nmap não está instalado."
  echo "Instale com: sudo apt install nmap"
  exit 1
fi
# Se nmap não existir, o script é encerrado

# ----------------------------------------------------------
# Início do processo
# ----------------------------------------------------------
{
# Bloco de comandos cuja saída será redirecionada para o log

echo "=================================================="
echo " VARREDURA DE PORTAS NA REDE"
echo " Rede alvo : $REDE_ALVO"
echo " Data      : $(date)"
# Exibe data

echo "=================================================="
echo

# ----------------------------------------------------------
# Etapa 1 - Descoberta de hosts ativos
# ----------------------------------------------------------
echo ">> Descobrindo hosts ativos na rede..."

HOSTS_ATIVOS=$(nmap -sn "$REDE_ALVO" | awk '/Nmap scan report/ {gsub(/[()]/,"",$NF); print $NF}')
# nmap -sn → faz apenas descoberta de hosts (ping scan)
# awk extrai o IP dos hosts encontrados e remove possíveis parênteses
# que aparecem quando o nmap mostra hostname + IP

if [ -z "$HOSTS_ATIVOS" ]; then
# -z verifica se a variável está vazia

  echo "Nenhum host ativo encontrado."
  exit 0
fi

echo "Hosts encontrados:"
for host in $HOSTS_ATIVOS; do
  echo " - $host"
done
# Exibe todos os hosts ativos encontrados

echo

# ----------------------------------------------------------
# Etapa 2 - Escaneamento de portas
# ----------------------------------------------------------
echo ">> Iniciando escaneamento de portas..."

for host in $HOSTS_ATIVOS
do
  echo "--------------------------------------------------"
  echo "Host: $host"
  echo "--------------------------------------------------"

  nmap -sS -sV -p "$PORTAS" "$host" | awk '
    /open/ {
      printf "Porta: %-7s Estado: %-6s Serviço: %s\n", $1, $2, $3
    }
  '
  # -sS → SYN Scan (escaneamento rápido e comum)
  # -sV → tenta identificar versão do serviço
  # -p  → define portas específicas para escanear
  # awk filtra apenas linhas com portas abertas

  echo
done

echo "=================================================="
echo "Varredura finalizada."
echo "Log salvo em: $ARQUIVO_LOG"
echo "=================================================="

} | tee "$ARQUIVO_LOG"
# tee exibe a saída no terminal e grava no arquivo de log

exit 0
# Finaliza o script com código de sucesso
