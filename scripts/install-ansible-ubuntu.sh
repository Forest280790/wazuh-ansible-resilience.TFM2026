#!/bin/bash
# Actualización del sistema e instalación del motor core de Ansible
echo "Actualizando repositorios e instalando dependencias..."
sudo apt update
sudo apt install ansible python3-pip -y

# Instalación del conector WinRM para interoperabilidad Linux-to-Windows
pip3 install pywinrm
echo "Entorno de control listo."
