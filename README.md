# wazuh-ansible-resilience.TFM2026
# Automatización del Despliegue de Agentes Wazuh con Ansible

Este repositorio contiene el código de automatización desarrollado como parte del trabajo de grado titulado **Evaluación de Desempeño y Resiliencia en Arquitecturas SIEM Geodistribuidas: Validación experimental de la integridad de registros y disponibilidad de telemetría sobre infraestructura física SD-WAN con cifrado de borde** para optar al título de Máster Universitario en Ciberseguridad en la Universidad Internacional de La Rioja (UNIR).

El objetivo principal de este proyecto es automatizar el aprovisionamiento, instalación, configuración y optimización (*tuning*) de los agentes de **Wazuh** en nodos remotos de la red, garantizando un despliegue rápido, estandarizado y seguro, con un enfoque particular en la resiliencia del almacenamiento local de eventos frente a cortes en el canal de comunicación perimetral.

---

## 🚀 Características
* **Instalación automática:** Despliegue desatendido y silencioso del agente Wazuh sobre sistemas operativos Windows 11.
* **Tuning de Resiliencia:** Configuración automatizada del módulo `client_buffer` en el archivo `ossec.conf` para la retención local de logs durante fallos de conectividad.
* **Inscripción Segura:** Registro centralizado y vinculación automática del agente con el Wazuh Manager a través de túneles cifrados.
* **Verificación Operativa:** Scripts integrados para auditoría de recursos en tiempo real tanto en el Endpoint como en el backend del Manager.

---

## 📋 Prerrequisitos

Antes de ejecutar este proyecto, asegúrese de cumplir con los siguientes requerimientos:

1. **Ansible Engine:** Instalado en el Nodo de Control (Ubuntu Server v1) con la librería `pywinrm` para la gestión remota de Windows.
2. **Conectividad WinRM:** Administración remota de Windows configurada y habilitada en el nodo destino.
3. **Reglas de Firewall:** Puertos `5985` (WinRM HTTP) y `1514/1515` (Wazuh) abiertos y permitidos a través de la infraestructura SD-WAN/WireGuard.
4. **Wazuh Manager:** Un servidor centralizado activo y accesible en la red interna de gestión.

---

## 🛠️ Estructura del Proyecto

El repositorio está organizado de la siguiente manera:

```text
├── 📂 network/
│   ├── 📄 bogota_core.rsc          # Configuración del MikroTik Central (Bogotá)
│   └── 📄 cucuta_edge.rsc          # Configuración del MikroTik de la Sucursal (Cúcuta)
├── 📂 scripts/
│   ├── 📄 bootstrap-win11.ps1       # Configura WinRM y Firewall en el Endpoint Windows
│   └── 📄 install-ansible-ubuntu.sh # Automatiza la instalación de Ansible y dependencias
├── 📂 tests/
│   ├── 📄 monitor_manager_ubuntu.sh # Evalúa consumo de CPU/RAM y conteo de alertas en el SIEM
│   ├── 📄 monitor_recursos_win11.ps1 # Captura métricas locales del agente y estado de red (netstat)
│   └── 📄 simulacion_corte_20k.ps1   # Inyector de estrés (20,000 logs) con disparador de corte de WAN
├── 📄 hosts.ini                      # Inventario de Ansible con credenciales y variables WinRM
├── 📄 instalar_agente.yml            # Playbook principal de despliegue DevSecOps y tuning del búfer
├── 📄 DEPLOYMENT.md
└── 📄 README.md                      # Documentación del proyecto
