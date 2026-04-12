#!/bin/bash
# ==========================================================
# SCRIPT: Auditoria Básica de Portas e Serviços no Host Local
#
# Objetivo:
#   Realizar auditoria básica de portas TCP/UDP abertas no
#   servidor local, identificando serviços em escuta e
#   verificando status do firewall.
#
# Cenário:
#   Utilizado para:
#   - Hardening inicial de servidores
#   - Verificação pós-instalação de serviços
#   - Troubleshooting de firewall (UFW)
#   - Auditoria rápida de exposição de portas
#
# Funcionamento:
#   - Cria diretório de logs automaticamente
#   - Valida execução como root
#   - Verifica disponibilidade do comando ss
#   - Lista portas TCP em estado LISTEN
#   - Lista portas UDP ativas
#   - Exibe status detalhado do firewall UFW
#   - Gera log com data e hora
#
# Diferencial Técnico:
#   - Uso do comando ss (substituto moderno do netstat)
#   - Filtro e formatação com awk para melhor legibilidade
#   - Geração automática de log versionado por timestamp
#   - Validação de pré-requisitos antes da execução
#   - Estrutura compatível com rotinas de auditoria
#
# Autor: Francklin Leandro
# Data: 23/02/2026
#
# Requisitos:
#   - bash
#   - iproute2 (comando ss)
#   - ufw (opcional, para verificação de firewall)
#
# Diretório de Logs:
#   $HOME/rede/logs
#
# Uso:
#   sudo ./auditoria_portas.sh
# ==========================================================

# Diretório e arquivo de log
DIRETORIO_LOG="$HOME/rede/logs"
ARQUIVO_LOG="$DIRETORIO_LOG/auditoria_portas_$(date +%d-%m-%Y).log"

# ----------------------------------------------------------
# Cria diretório de logs se não existir
# ----------------------------------------------------------
mkdir -p "$DIRETORIO_LOG"

# ----------------------------------------------------------
# Verifica se o script está sendo executado como root
# Necessário para visualizar todos os processos/portas
# ----------------------------------------------------------
if [ "$EUID" -ne 0 ]; then
  echo "ERRO: execute este script como root (sudo)." | tee "$ARQUIVO_LOG"
  # tee escreve no arquivo de log (sobrescrevendo)
  exit 1
  # Sai do script
fi

# ----------------------------------------------------------
# Verifica se o comando ss está disponível
# (padrão no Ubuntu, pacote iproute2)
# ----------------------------------------------------------
if ! command -v ss &>/dev/null; then
  echo "ERRO: comando 'ss' não encontrado." | tee "$ARQUIVO_LOG"
  exit 1
fi

# ----------------------------------------------------------
# Início da auditoria
# ----------------------------------------------------------
{
echo "=================================================="
echo " AUDITORIA BÁSICA DE PORTAS E SERVIÇOS"
echo " Host : $(hostname)"
echo " Data : $(date)"
echo "=================================================="
echo

# ----------------------------------------------------------
# Lista portas TCP em escuta
# ----------------------------------------------------------
# $2 == "LISTEN": filtra apenas sockets em estado LISTEN
# $4 = endereço:porta | $7 = processo associado
echo ">> Portas TCP em LISTEN"
echo "--------------------------------------------------"
ss -tulnp | awk ' 
  $2 == "LISTEN" {
    printf "PROTO: TCP | ENDEREÇO: %-22s | SERVIÇO: %s\n", $4, $7
  }
'
echo

# ----------------------------------------------------------
# Lista portas UDP abertas
# ----------------------------------------------------------
# NR > 1: Ignora cabeçalho da saída
# $4 = endereço | $6 = processo (formato diferente do TCP)
echo ">> Portas UDP ativas"
echo "--------------------------------------------------"
ss -uulnp | awk '
  NR > 1 {
    printf "PROTO: UDP | ENDEREÇO: %-22s | SERVIÇO: %s\n", $4, $6
  }
'
echo

# ----------------------------------------------------------
# Verifica status do firewall UFW
# ----------------------------------------------------------
echo ">> Status do Firewall (UFW)"
echo "--------------------------------------------------"
if command -v ufw &>/dev/null; then
  ufw status verbose
else
  echo "UFW não está instalado."
fi
echo

# ----------------------------------------------------------
# Observações finais
# ----------------------------------------------------------
echo "=================================================="
echo " Observações:"
echo " - Verifique se há serviços desnecessários expostos."
echo " - Compare as portas abertas com a política de segurança."
echo " - Em servidores, menos portas abertas = menor superfície de ataque."
echo "=================================================="
echo " Log salvo em: $ARQUIVO_LOG"
echo "=================================================="

} | tee "$ARQUIVO_LOG"

exit 0
