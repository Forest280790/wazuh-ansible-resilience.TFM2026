#!/bin/bash
AGENT_ID="007"
REPORT_FILE="/root/metricas_tfm.log"
echo "=== REPORTE DE RESILIENCIA WAZUH UBUNTU ===" > "$REPORT_FILE"
echo "Monitoreando Agente ID: $AGENT_ID" >> "$REPORT_FILE"
echo "------------------------------------------------------------" >> "$REPORT_FILE"
while true; do
    TIME=$(date +"%H:%M:%S")
    ESTADO=$(/var/ossec/bin/agent_control -i "$AGENT_ID" 2>/dev/null | grep -i "Status" | awk -F": " '{print $2}' | tr -d " ")
    if [ -z "$ESTADO" ]; then ESTADO="UNKNOWN"; fi
    RECURSOS=$(ps -C wazuh-apid,wazuh-analysisd,wazuh-remoted -o %cpu,%mem --no-headers 2>/dev/null | awk '{cpu+=$1; mem+=$2} END {print "CPU: "cpu"% | RAM: "mem"%"}')
    if [ -z "$RECURSOS" ]; then RECURSOS="CPU: 0% | RAM: 0%"; fi
    ALERTAS_RECIBIDAS=$(grep -c "99" /var/ossec/logs/archives/archives.json 2>/dev/null || grep -c "\"category\":99" /var/ossec/logs/alerts/alerts.json 2>/dev/null || echo "0")
    LOG_LINE="[$TIME] Agente [$AGENT_ID]: $ESTADO | Manager $RECURSOS | Alertas: $ALERTAS_RECIBIDAS"
    echo "$LOG_LINE"
    echo "$LOG_LINE" >> "$REPORT_FILE"
    sleep 2
done
