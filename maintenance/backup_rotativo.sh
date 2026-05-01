#!/bin/bash
# ==========================================================
# SCRIPT: Backup Automatizado com Compressão e Rotação
#
# Objetivo:
#   Realizar backup de diretórios críticos do sistema,
#   aplicando compressão e rotação automática para manter
#   apenas os arquivos mais recentes.
#
# Cenário:
#   Utilizado para:
#   - Backup de configurações do sistema (/etc)
#   - Backup de logs do sistema (/var/log) para análise e troubleshooting
#   - Rotinas de manutenção em servidores Linux
#   - Prevenção de perda de dados em ambientes corporativos
#
# Funcionamento:
#   - Define diretórios a serem incluídos no backup
#   - Cria diretório de destino se não existir
#   - Gera arquivo compactado (.tar.gz) com data no nome
#   - Registra todas as ações em arquivo de log
#   - Valida sucesso da operação de backup
#   - Lista backups existentes ordenados por data
#   - Remove backups antigos excedentes (rotação)
#
# Diferencial Técnico:
#   - Uso de array para múltiplos diretórios
#   - Compressão com tar + gzip
#   - Rotação automática baseada em quantidade máxima
#   - Registro contínuo de logs com tee
#   - Estrutura adequada para agendamento via cron
#
# Autor: Francklin Leandro
# Data: 30/04/2026
#
# Requisitos:
#   - bash
#   - tar
#
# Diretório de Backup:
#   $HOME/backups
#
# Uso:
#   ./backup_rotativo.sh
# ==========================================================

# -------------------------
# CONFIGURAÇÕES
# -------------------------

# Diretórios que serão incluídos no backup
DIRETORIOS_BACKUP=("/etc" "/var/log")

# Diretório onde os backups serão armazenados
DESTINO_BACKUP="$HOME/backups"

# Quantidade máxima de backups a manter
MAX_BACKUPS=5

# Nome base do arquivo
DATA=$(date +%d-%m-%Y)
ARQUIVO_BACKUP="$DESTINO_BACKUP/backup_$DATA.tar.gz"

# Arquivo de log
LOG="$DESTINO_BACKUP/backup.log"

# ---------------------------------------
# CRIA DIRETÓRIO DE BACKUP SE NÃO EXISTIR
# ---------------------------------------
mkdir -p "$DESTINO_BACKUP"

# -------------------------
# INÍCIO DO PROCESSO
# -------------------------
echo "==================================================" | tee -a "$LOG"
echo " INÍCIO DO BACKUP - $(date)" | tee -a "$LOG"
echo "==================================================" | tee -a "$LOG"

# -------------------------
# EXECUTA BACKUP
# -------------------------
echo "Compactando diretórios..." | tee -a "$LOG"

sudo tar -czpf "$ARQUIVO_BACKUP" "${DIRETORIOS_BACKUP[@]}" 2>>"$LOG"
# -c cria | -z gzip | -p preserva permissões | -f arquivo
# ${DIRETORIOS_BACKUP[@]} expande todos os diretórios corretamente
# 2>> redireciona erros para o log

# Verifica se o backup foi criado com sucesso
if [ $? -eq 0 ]; then
  echo "Backup criado com sucesso: $ARQUIVO_BACKUP" | tee -a "$LOG"
else
  echo "ERRO ao criar backup." | tee -a "$LOG"
  exit 1 # Encerra o script com erro
fi

# -------------------------
# ROTAÇÃO DE BACKUPS
# Mantém apenas os mais recentes
# -------------------------
echo "Aplicando rotação de backups..." | tee -a "$LOG"

BACKUPS_EXISTENTES=($(ls -t "$DESTINO_BACKUP"/backup_*.tar.gz 2>/dev/null))
# ls -t ordena por data (mais recentes primeiro)
# 2>/dev/null evita erro se não houver arquivos

TOTAL=${#BACKUPS_EXISTENTES[@]}
# Conta quantidade total de backups existentes

if [ "$TOTAL" -gt "$MAX_BACKUPS" ]; then
# Só executa rotação se exceder o limite

  for ((i=MAX_BACKUPS; i<TOTAL; i++)); do
  # Começa a remover a partir do índice limite

    echo "Removendo backup antigo: ${BACKUPS_EXISTENTES[$i]}" | tee -a "$LOG"
    rm -f "${BACKUPS_EXISTENTES[$i]}"
    # Remove arquivos mais antigos(Recursivo forçado)
  done
fi

# -------------------------
# FINALIZAÇÃO
# -------------------------
echo "==================================================" | tee -a "$LOG"
echo " BACKUP FINALIZADO - $(date)" | tee -a "$LOG"
echo "==================================================" | tee -a "$LOG"

exit 0 
# Encerra o script com sucesso
