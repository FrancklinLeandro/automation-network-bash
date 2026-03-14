# automation-network-bash
## Objetivo do Repositório
Este repositório contém scripts **Bash** voltados para automação em **Infraestrutura de Redes**.
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
