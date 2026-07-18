# 📖 Guía de Despliegue y Verificación Operativa

Esta guía técnica detalla los pasos cronológicos para verificar la conectividad remota y ejecutar el aprovisionamiento automatizado del agente Wazuh desde el Nodo de Control (Ubuntu Server) hacia el Endpoint (Windows 11).

---

## 🔍 Paso 1: Verificación de Conectividad WinRM (`win_ping`)

Antes de iniciar el aprovisionamiento, es obligatorio validar que el canal de comunicación remota cifrada por WinRM, las llaves de acceso y las reglas de Firewall estén operativas a través del túnel SD-WAN.

### Comando de ejecución en Ubuntu:
```bash
ansible windows -i hosts.ini -m win_ping


##Salida esperada en pantalla (Éxito):
192.168.200.120 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}

Paso 2: Ejecución del Playbook Principal (ansible-playbook)
ansible-playbook -i hosts.ini instalar_agente.yml
