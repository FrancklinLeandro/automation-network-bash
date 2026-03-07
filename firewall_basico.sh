#!/bin/bash
# ==========================================================
# SCRIPT: Firewall Básico com IPTABLES para Servidor Ubuntu
#
# Objetivo:
#   Aplicar política de firewall restritiva em servidor Ubuntu,
#   liberando apenas serviços essenciais e bloqueando todo o
#   restante por padrão.
#
# Cenário:
#   Utilizado para:
#   - Servidor recém-instalado antes de entrar em produção
#   - Hardening inicial de ambiente Linux
#   - Controle manual de regras sem uso de UFW
#   - Laboratórios de segurança e testes de exposição
#
# Funcionamento:
#   - Valida execução como root
#   - Limpa todas as regras existentes (filter, nat, mangle)
#   - Define políticas padrão:
#       INPUT: DROP
#       FORWARD: DROP
#       OUTPUT: ACCEPT
#   - Permite tráfego loopback
#   - Permite conexões já estabelecidas (ESTABLISHED, RELATED)
#   - Libera SSH apenas para rede autorizada(Cliente)
#   - Libera HTTP (80) e HTTPS (443)
#   - Registra tentativas bloqueadas com limitação de log
#   - Exibe resumo final das regras ativas
#
# Diferencial Técnico:
#   - Política default DROP (modelo deny-by-default)
#   - Uso de conntrack para controle de estado
#   - Log rate-limited para evitar flood
#   - Estrutura clara para expansão de novas regras
#   - Foco em princípio do menor privilégio
#
# Autor: Francklin Leandro
# Data: 23/02/2026
#
# Requisitos:
#   - bash
#   - iptables
#   - Permissão root
#
# Observação:
#   As regras não são persistentes por padrão.
#   Para persistência:
#     sudo apt install iptables-persistent
#     sudo netfilter-persistent save
#
# Uso:
#   sudo ./firewall_basico.sh
# ==========================================================

# -------------------------
# CONFIGURAÇÕES
# -------------------------
REDE_SSH="10.x.x.x/24"   # Rede autorizada(Cliente) a acessar SSH
PORTA_SSH=22

# -------------------------
# Verifica se é root
# -------------------------
if [ "$EUID" -ne 0 ]; then
  echo "ERRO: Execute como root (sudo)."
  exit 1
fi

echo "Aplicando regras de firewall com iptables..."
sleep 2

# -------------------------
# Limpa regras existentes
# -------------------------
iptables -F
iptables -X
iptables -t nat -F
iptables -t mangle -F

# -------------------------
# Define políticas padrão
# INPUT e FORWARD bloqueados
# OUTPUT liberado
# -------------------------
iptables -P INPUT DROP # Bloqueia tudo que chega ao servidor (exceto regras permitidas).
iptables -P FORWARD DROP # Bloqueia tráfego passando pela máquina (gateway).
iptables -P OUTPUT ACCEPT # Permite servidor iniciar conexões para fora livremente.

# -------------------------
# Permite tráfego local (loopback)
# Fundamental para serviços internos
# -------------------------
iptables -A INPUT -i lo -j ACCEPT

# -------------------------
# Permite conexões já estabelecidas
# Evita quebrar conexões ativas
# -------------------------
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# -------------------------
# Libera SSH apenas para rede autorizada
# s(Source): Máquina cliente/origem
# -------------------------
iptables -A INPUT -p tcp -s "$REDE_SSH" --dport "$PORTA_SSH" -m conntrack --ctstate NEW -j ACCEPT

# -------------------------
# Libera HTTP (porta 80)
# -------------------------
iptables -A INPUT -p tcp --dport 80 -m conntrack --ctstate NEW -j ACCEPT

# -------------------------
# Libera HTTPS (porta 443)
# -------------------------
iptables -A INPUT -p tcp --dport 443 -m conntrack --ctstate NEW -j ACCEPT

# -------------------------
# Loga tentativas bloqueadas (limitado)
# Evita flood de logs
# -------------------------
iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "IPTABLES DROP: " --log-level 4

echo "Regras aplicadas com sucesso."
echo
echo "Resumo das regras ativas:"
iptables -L -n -v

echo
echo "ATENÇÃO:"
echo "- Para tornar permanente, salve com:"
echo "  sudo apt install iptables-persistent"
echo "  sudo netfilter-persistent save"

exit 0
