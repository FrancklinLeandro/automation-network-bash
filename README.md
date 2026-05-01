# 🚀 automation-network-bash

## 🎯 Objetivo

Repositório de automação em **Bash** voltado para **infraestrutura Linux, redes e operações**, com foco em cenários reais de ambiente corporativo.

Os scripts foram desenvolvidos para:

- Administração e monitoramento de infraestrutura Linux  
- Diagnóstico e troubleshooting de conectividade  
- Auditoria de segurança básica  
- Coleta e análise de informações de sistema e rede  
- Automação de tarefas operacionais  

---

## 🔥 Casos de Uso

Os scripts simulam atividades comuns em ambientes de:

- Infraestrutura Linux  
- NOC (Network Operations Center)  
- Operações de rede  
- Administração de sistemas  
- Auditoria e troubleshooting  

---

## 🛠️ Tipos de Automação

- Verificação de portas TCP (netcat)  
- Monitoramento de hosts e latência  
- Descoberta de dispositivos na rede (ARP Scan, Nmap)  
- Análise de tráfego e interfaces  
- Auditoria de firewall e serviços  
- Comparação de inventário (NetBox vs CSV)  
- Diagnóstico de rota com geração de logs  

Todos os scripts incluem documentação com:
- objetivo  
- requisitos  
- exemplo de uso  

---

## 📂 Scripts

### 🔎 TCP-port-checker.sh
Verificação de portas TCP em múltiplos hosts com **netcat**

### 🌐 traceroute.sh
Diagnóstico de rota com geração de **log diário**

### 📊 switch-netbox.sh
Auditoria de inventário (**NetBox vs CSV**)

### 📡 switch-csv.sh
Monitoramento de switches (status **UP/DOWN**)

### 🧠 nmap_network_scan.sh
Descoberta de hosts + varredura de portas com **Nmap**

### 📶 latency-monitor.sh
Monitoramento de latência e perda de pacotes

### 🖥️ host-monitor.sh
Verificação de disponibilidade de múltiplos hosts

### 🧬 host-arp-scan2.sh
Descoberta de dispositivos via **ARP Scan**

### 🔒 firewall_basico.sh
Configuração de firewall com **iptables (deny-by-default)**

### 📈 bandwidth-usage-monitor.sh
Monitoramento de tráfego via `/proc/net/dev`

### 🔍 auditoria_portas.sh
Auditoria de portas e serviços com `ss`

### 📡 ap-scan.sh
Monitoramento de Access Points (ICMP)

### 📄 DHCP-leases.sh
Análise de leases DHCP (IP, MAC, hostname)

### 💾 backup_rotativo.sh
Realiza backup automatizado de diretórios críticos com compressão (.tar.gz), rotação de arquivos antigos e registro detalhado em log

---

## 🗂️ Estrutura
```
automation-network-bash/
├── connectivity/
│   ├── TCP-port-checker.sh
│   ├── ap-scan.sh
│   ├── host-monitor.sh
│   ├── latency-monitor.sh
│   ├── switch-csv.sh
│   └── traceroute.sh
├── discovery/
│   ├── DHCP-leases.sh
│   ├── host-arp-scan2.sh
│   └── nmap_network_scan.sh
├── inventory/
│   └── switch-netbox.sh
├── maintenance/
│   └── backup_rotativo.sh
├── monitoring/
│   └── bandwidth-usage-monitor.sh
├── security/
│   ├── auditoria_portas.sh
│   └── firewall_basico.sh
├── NOTA.md
└── README.md
```
---

## 🚀 Diferencial

- Automação voltada para **infraestrutura Linux e administração de sistemas**  
- Scripts aplicáveis a **cenários reais de operação**  
- Uso de ferramentas padrão de mercado  
- Baixo overhead (uso direto do sistema Linux)  
- Foco em automação operacional e troubleshooting   
