# ==============================================================================
# Configuración MikroTik - Nodo Central: Core Bogotá
# Propósito: Hub concentrador SD-WAN WireGuard, ruteo inter-sucursales, NAT/DMZ
#            y reenvío de logs perimetrales hacia el SOC/SIEM (Wazuh Manager)
# Proyecto: TFM Ciberseguridad - UNIR 2026
# ==============================================================================

# model = RB5009UG+S+
# serial number = <SERIAL_OCULTADO_TFM>
# software id = <SOFTWARE_ID_OCULTADO>

/interface bridge
add comment="TFM: Switch Virtual LAN" name=bridge-LAN
/interface ethernet
set [ find default-name=ether1 ] name=ether1-WAN
set [ find default-name=ether2 ] name=ether2-LAN
/interface wireguard
add listen-port=51820 mtu=1420 name=wg-to-cucuta
add comment=configuracion listen-port=61287 mtu=1420 name=wg1-configuracion
/interface list
add name=WAN
add name=LAN
/ip pool
add name=dhcp-pool ranges=192.168.100.50-192.168.100.90
/ip dhcp-server
add address-pool=dhcp-pool interface=bridge-LAN name=dhcp-LAN
/system logging action
add name=Routerwazuh remote=192.168.100.50 target=remote
add name=routerwazuhfirewall remote=192.168.100.50 target=remote
add name=procesadorrouter target=memory
/interface bridge port
add bridge=bridge-LAN interface=ether2-LAN
add bridge=bridge-LAN interface=ether3
add bridge=bridge-LAN interface=ether4
add bridge=bridge-LAN interface=ether5
add bridge=bridge-LAN interface=ether6
add bridge=bridge-LAN interface=ether7
/interface list member
add interface=ether1-WAN list=WAN
add interface=bridge-LAN list=LAN
/interface wireguard peers
add allowed-address=10.200.200.2/32 client-allowed-address=::/0 comment="equipo portatil" interface=wg1-configuracion name=peer1 public-key="<LLAVE_PUBLICA_LAPTOP_ADMIN_SAMPLE=>"
add allowed-address=10.0.99.2/32,192.168.200.0/24,192.168.201.0/24 comment="TFM: Sucursal Cucuta" interface=wg-to-cucuta name=peer2 public-key="<LLAVE_PUBLICA_CUCUTA_EDGE_SAMPLE=>"
add allowed-address=10.0.99.6/32,192.168.210.0/24,192.168.211.0/24 comment="TFM: Sucursal 2" endpoint-address=181.49.X.X endpoint-port=51820 interface=wg-to-cucuta name=peer-S2 public-key="<LLAVE_PUBLICA_SUCURSAL2_SAMPLE=>"
/ip address
add address=186.155.200.60/27 interface=ether1-WAN network=186.155.200.32
add address=192.168.100.1/24 interface=bridge-LAN network=192.168.100.0
add address=10.200.200.1/24 interface=wg1-configuracion network=10.200.200.0
add address=10.0.99.1/30 interface=wg-to-cucuta network=10.0.99.0
add address=10.0.99.5/30 interface=wg-to-cucuta network=10.0.99.4
/ip dhcp-client
# Nota: La interfaz remanente dinámica (*C) ha sido omitida para evitar errores de sintaxis en el despliegue lógico.
/ip dhcp-server lease
add address=192.168.100.50 client-id=ff:56:50:4d:98:0:2:0:0:ab:11:2c:aa:9a:ad:bf:a0:b7:72 mac-address=D8:9E:F3:05:AA:BB server=dhcp-LAN
/ip dhcp-server network
add address=192.168.100.0/24 comment="TFM: Red DHCP LAN" dns-server=192.168.100.1,8.8.8.8 gateway=192.168.100.1
/ip dns
set allow-remote-requests=yes servers=8.8.8.8,1.1.1.1
/ip firewall filter
add action=accept chain=input comment="TFM: Permitir Ping desde Internet" protocol=icmp
add action=accept chain=input comment="TFM: Permitir WireGuard" dst-port=13231,61287 protocol=udp
add action=drop chain=input comment="LOG: Ataques al Router" dst-port=22,23,8291 in-interface=ether1-WAN log=yes log-prefix="[ALERTA_SCAN_ROUTER]" protocol=tcp
add action=drop chain=input comment="LOG: Paquetes Invalidos" connection-state=invalid log=yes log-prefix="[ALERTA_INVALID_PKT]"
add action=accept chain=forward comment="LOG: Accesos Web a CentOS" connection-state=new dst-address=192.168.100.10 dst-port=80,443 log=yes log-prefix="[ACCESO_WEB_CENTOS]" protocol=tcp
add action=accept chain=forward comment="LOG: Accesos Panel CWP" connection-state=new dst-address=192.168.100.10 dst-port=2030,2031 log=yes log-prefix="[ACCESO_PANEL_CWP]" protocol=tcp
add action=drop chain=forward comment="LOG: Ataques BD CentOS" dst-address=192.168.100.10 dst-port=3306 in-interface=ether1-WAN log=yes log-prefix="[ALERTA_SCAN_MYSQL]" protocol=tcp
add action=accept chain=forward comment="PASO FORZADO CWP" dst-address=192.168.100.10
add action=accept chain=input comment="Aceptar trafico interno" connection-state=established,related
add action=accept chain=input comment="TFM: Permitir WireGuard desde Ccuta" dst-port=51820 protocol=udp
add action=accept chain=input comment="TFM: Permitir Winbox desde LAN Cucuta" dst-port=8291 protocol=tcp src-address=192.168.200.0/24
add action=drop chain=input comment="Drop absoluto desde WAN" in-interface=ether1-WAN
add action=accept chain=forward comment="Permitir LAN a Internet" connection-state=established,related
add action=accept chain=forward comment="Permitir Port Forwarding" connection-nat-state=dstnat
add action=drop chain=forward comment="Drop ataques a la LAN" connection-state=new in-interface=ether1-WAN
/ip firewall nat
add action=masquerade chain=srcnat comment="TFM: Salida a internet para la LAN" out-interface=ether1-WAN
add action=dst-nat chain=dstnat comment="TFM: Trafico HTTPS Web (443)" dst-address=186.155.200.60 dst-port=443 protocol=tcp to-addresses=192.168.100.10 to-ports=443
add action=dst-nat chain=dstnat comment="TEST: Log CWP" dst-address=186.155.200.60 dst-port=2030 log=yes log-prefix="-> INTENTO_CWP" protocol=tcp to-addresses=192.168.100.10 to-ports=2030
add action=dst-nat chain=dstnat comment="CWP HTTP Seguro" dst-address=186.155.200.60 dst-port=2030 protocol=tcp to-addresses=192.168.100.10 to-ports=2030
add action=dst-nat chain=dstnat comment="CWP HTTPS Seguro" dst-address=186.155.200.60 dst-port=2031 protocol=tcp to-addresses=192.168.100.10 to-ports=2031
add action=dst-nat chain=dstnat comment="TFM: Puertos TCP IN (Parte 1)" dst-address=186.155.200.60 dst-port=20,21,25,53,80,110,143,443,465,587 protocol=tcp to-addresses=192.168.100.10
add action=dst-nat chain=dstnat comment="TFM: Puertos TCP IN (Parte 2)" dst-address=186.155.200.60 dst-port=853,993,995,2030,2031,2082,2083 protocol=tcp to-addresses=192.168.100.10
add action=dst-nat chain=dstnat comment="TFM: Puertos TCP IN (Parte 3)" dst-address=186.155.200.60 dst-port=2086,2087,2095,2096 protocol=tcp to-addresses=192.168.100.10
add action=dst-nat chain=dstnat comment="TFM: Puertos UDP IN" dst-address=186.155.200.60 dst-port=20,21,53,80,443,853 protocol=udp to-addresses=192.168.100.10
add action=dst-nat chain=dstnat dst-port=5201 protocol=tcp to-addresses=192.168.100.10 to-ports=5201
add action=dst-nat chain=dstnat dst-port=5201 protocol=udp to-addresses=192.168.100.10 to-ports=5201
add action=dst-nat chain=dstnat in-interface=ether1-WAN protocol=icmp to-addresses=192.168.100.10
/ip route
add comment="TFM: Salida a Internet" distance=1 gateway=186.155.200.33
add comment="TFM: Ruta hacia LAN Cucuta" dst-address=192.168.200.0/24 gateway=wg-to-cucuta
add comment="TFM: Ruta hacia DMZ Cucuta" dst-address=192.168.201.0/24 gateway=wg-to-cucuta
add comment="TFM: Ruta hacia LAN S2" dst-address=192.168.210.0/24 gateway=wg-to-cucuta
add comment="TFM: Ruta hacia DMZ S2" dst-address=192.168.211.0/24 gateway=wg-to-cucuta
/ip service
set ftp disabled=yes
set ssh address=192.168.100.0/24
set telnet disabled=yes
set www disabled=yes
set winbox address=192.168.100.0/24,10.0.88.0/30,192.168.200.0/24
set api disabled=yes
set api-ssl disabled=yes
/system clock
set time-zone-name=America/Bogota
/system logging
set 0 action=Routerwazuh
add action=routerwazuhfirewall topics=firewall
