# automation-network-bash
## Objetivo do Repositório
Este repositório contém scripts **Bash** voltados para automação em **Infraestrutura, Redes, suporte e segurança**.
O foco é:
- Diagnóstico de conectividade
- Auditoria básica de segurança
- Monitoramento de dispositivos
- Automatização de tarefas repetitivas em ambientes Linux

Os scripts são desenvolvidos para uso prático em **laboratórios e ambientes corporativos**.

---

## Tipos de Automações
Este repositório inclui automações como:
- Verificação de portas TCP
- Testes de conectividade (ping, nc)
- Coleta de informações de rede
- Monitoramento de interfaces
- Scripts auxiliares para troubleshooting
- Diagnóstico de rota (traceroute) para múltiplos destinos com geração automática de log diário
- Auditoria de inventário de switches (comparação entre NetBox e planilha CSV)

Cada script contém **documentação detalhada no próprio código**, incluindo:
- objetivo
- requisitos
- exemplo de uso

---

## Scripts

### TCP-port-checker.sh
Verifica portas TCP em múltiplos hosts utilizando **netcat**, permitindo identificar rapidamente serviços acessíveis em dispositivos de rede.

**Uso:**

```bash
./TCP-port-checker.sh hosts.txt
```

### traceroute.sh
Executa **diagnóstico de rota (traceroute)** para múltiplos destinos definidos em um arquivo, registrando automaticamente os resultados em **log diário** para análise de caminho e troubleshooting de rede.

**Uso:**

```bash
./traceroute.sh
```

### switch-netbox.sh
Compara inventários de switches entre **NetBox** e uma **planilha CSV**, identificando inconsistências como dispositivos presentes em uma base e ausentes na outra. Gera relatório automático em **arquivo de log** para auditoria de inventário de rede.

**Uso:**

```bash
./switch-netbox.sh
```

### switch-csv.sh
Realiza **teste de conectividade (ping)** em switches listados em arquivos **CSV**, identificando dispositivos **UP ou DOWN** e gerando relatório consolidado em **log diário** para auditoria de disponibilidade da rede.

**Uso:**

```bash
./switch-csv.sh
```

### nmap_network_scan.sh
Realiza **descoberta de hosts ativos** em uma rede e executa **varredura de portas TCP comuns utilizando Nmap**, identificando serviços em execução e registrando os resultados em **log diário** para auditoria e troubleshooting de infraestrutura.

**Uso:**

```bash
sudo ./nmap_network_scan.sh
```

### latency-monitor.sh
Monitora **latência média e perda de pacotes** para múltiplos destinos utilizando **ping**, registrando os resultados em **log diário** para análise de qualidade de rede e diagnóstico de instabilidade.

**Uso:**

```bash
./latency-monitor.sh
```

### host-monitor.sh
Realiza **monitoramento de conectividade** para múltiplos hosts utilizando **ping**, classificando cada destino como **UP ou DOWN** e registrando os resultados em **log diário** com resumo final da disponibilidade.

**Uso:**

```bash
./host-monitor.sh
```

### host-arp-scan2.sh
Realiza **descoberta de dispositivos na rede local** utilizando **ARP Scan**, identificando IP, endereço MAC e fabricante dos equipamentos e registrando os resultados em **log diário** para inventário e auditoria de rede.

**Uso:**

```bash
sudo ./host-arp-scan2.sh
```

### firewall_basico.sh
Aplica **configuração básica de firewall com iptables** em servidores Linux, utilizando política **deny-by-default**, liberando apenas serviços essenciais (SSH restrito, HTTP e HTTPS) para hardening inicial de ambientes Ubuntu.

**Uso:**

```bash
sudo ./firewall_basico.sh
```

### bandwidth-usage-monitor.sh
Monitora o **tráfego de rede (RX/TX)** de uma interface Linux, calculando a taxa de recebimento e transmissão em **KB/s** a partir dos dados do `/proc/net/dev`, permitindo análise básica de consumo de banda e identificação de picos de tráfego.

**Uso:**

```bash
./bandwidth-usage-monitor.sh
```

### auditoria_portas.sh
Realiza **auditoria básica de portas TCP/UDP e serviços ativos no host local**, utilizando `ss` para identificar portas em escuta e verificando também o **status do firewall UFW**, auxiliando em processos de hardening e diagnóstico de exposição de serviços.

**Uso:**

```bash
sudo ./auditoria_portas.sh
```

### ap-scan.sh
Realiza **monitoramento de conectividade de Access Points (APs)** por meio de testes ICMP (`ping`), lendo uma lista estruturada de dispositivos e registrando **status UP/DOWN em logs**, facilitando auditoria e acompanhamento de disponibilidade da infraestrutura Wi-Fi.

**Uso:**

```bash
./ap-scan.sh
```

### DHCP-leases.sh
Analisa **arquivos de concessões DHCP (leases)** gerados pelo NetworkManager/dhclient, extraindo informações como **IP concedido, MAC Address, hostname e data de expiração**, gerando um relatório estruturado para auditoria de dispositivos na rede.

**Uso:**

```bash
sudo ./DHCP-leases.sh
```

## Estrutura do Repositório
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
├── monitoring/
│   └── bandwidth-usage-monitor.sh
├── security/
│   ├── auditoria_portas.sh
│   └── firewall_basico.sh
├── NOTA.md
└── README.md
```
