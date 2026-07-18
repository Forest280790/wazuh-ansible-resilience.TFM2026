# wazuh-ansible-resilience.TFM2026
# Automatización del Despliegue de Agentes Wazuh con Ansible

Este repositorio contiene el código de automatización desarrollado como parte del trabajo de grado titulado **Evaluación de Desempeño y Resiliencia en Arquitecturas SIEM Geodistribuidas: Validación experimental de la integridad de registros y disponibilidad de telemetría sobre infraestructura física SD-WAN con cifrado de borde.** para optar al título de Master Universitario en Ciberseguridad en la Universidad Internacional de La Rioja.

El objetivo principal de este proyecto es automatizar el aprovisionamiento, instalación y configuración de los agentes de **Wazuh** en diferentes nodos de la red, garantizando un despliegue rápido, estandarizado y seguro conectado al Wazuh Manager.

---

## 🚀 Características
*   Instalación automática del agente Wazuh según el sistema operativo (soporte para Windows 11).
*   Configuración automatizada del archivo `ossec.conf` para apuntar al Manager correspondiente.
*   Inscripción automática y segura del agente mediante llaves/certificados.
*   Verificación y arranque del servicio del agente de forma centralizada.

---

## 📋 Prerrequisitos

Antes de ejecutar este playbook, asegúrate de contar con los siguientes requerimientos:

1.  **Ansible:** Instalado en la máquina de control (versión 2.10 o superior recomendada).
2.  **Accesibilidad SSH:** Acceso SSH configurado mediante llaves públicas/privadas hacia los nodos destino (agentes).
3.  **Accesibilidad WinRM:** Acceso desatendido para la instalación del agente en Windows.
3.  **Wazuh Manager:** Un servidor Wazuh Manager activo y accesible en la red.

---

## 🛠️ Estructura del Proyecto

```text
├── roles/
│   └── wazuh-agent/            # Rol principal para la configuración del agente
│       ├── tasks/              # Tareas de instalación y configuración
│       ├── templates/          # Plantilla del archivo ossec.conf.j2
│       └── vars/               # Variables por defecto
├── inventory.ini               # Inventario con las IPs de los nodos destino
├── site.yml                    # Playbook principal de ejecución
└── README.md                   # Documentación del proyecto
