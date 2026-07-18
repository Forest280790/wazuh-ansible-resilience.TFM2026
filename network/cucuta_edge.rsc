# ==============================================================================
# Configuración MikroTik - Nodo de Borde: Sucursal Cúcuta
# Propósito: Enrutamiento local, DMZ, Firewall perimetral y túnel SD-WAN WireGuard
# Proyecto: TFM Ciberseguridad - UNIR 2026
# ==============================================================================

# model = RB951G-2HnD
# serial number = <SERIAL_OCULTADO_TFM>
# software id = <SOFTWARE_ID_OCULTADO>

/interface bridge
add admin-mac=D4:CA:6D:AA:BB:CC auto-mac=no comment="TFM: Switch Virtual LAN" \
    name=bridge-LAN
/interface ethernet
set [ find default-name=ether1 ] name=ether1-WAN
set [ find default-name=ether2 ] name=ether2-LAN
set [ find default-name=ether3 ] name=ether3-LAN2
set [ find default-name=ether4 ] name=ether4-LAN3
set [ find default-name=ether5 ] name=ether5-DMZ
/interface wireguard
add listen-port=51820 mtu=1420 name=wg-to-bogota
/interface list
add name=WAN
add name=LAN
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
add authentication-types=wpa2-psk mode=dynamic-keys name=Perfil-WiFi-Cucuta \
    supplicant-identity=MikroTik
/interface wireless
set [ find default-name=wlan1 ] band=2ghz-onlyn channel-width=20/40mhz-Ce \
    disabled=no frequency=auto mode=ap-bridge security-profile=\
    Perfil-WiFi-Cucuta ssid=WiFi_Cucuta_TFM wireless-protocol=802.11
/ip pool
add name=pool-LAN ranges=192.168.200.50-192.168.200.150
add name=pool-DMZ ranges=192.168.201.50-192.168.201.150
/ip dhcp-server
add address-pool=pool-LAN interface=bridge-LAN name=dhcp-LAN
add address-pool=pool-DMZ interface=ether5-DMZ name=dhcp-DMZ
/system logging action
add name=remotorb951 remote=192.168.100.50 target=remote
add name=firewallrb951 remote=192.168.100.50 target=remote
/interface bridge port
add bridge=bridge-LAN interface=ether2-LAN
add bridge=bridge-LAN interface=ether3-LAN2
add bridge=bridge-LAN interface=ether4-LAN3
add bridge=bridge-LAN comment="TFM: Puerto inalambrico LAN" interface=wlan1
/interface list member
add interface=ether1-WAN list=WAN
add interface=bridge-LAN list=LAN
/interface wireguard peers
add allowed-address=10.0.99.1/32,192.168.100.0/24 comment=\
    "Conexion al SOC Bogota" endpoint-address=185.155.X.X endpoint-port=\
    51820 interface=wg-to-bogota name=peer1 persistent-keepalive=25s \
    public-key="<LLAVE_PUBLICA_WIREGUARD_BOGOTA_SOC_SAMPLE_KEY=>"
/ip address
add address=192.168.200.1/24 interface=bridge-LAN network=192.168.200.0
add address=192.168.201.1/24 interface=ether5-DMZ network=192.168.201.0
add address=10.0.99.2/30 interface=wg-to-bogota network=10.0.99.0
/ip dhcp-client
add comment="WAN Dinamica Universal" interface=ether1-WAN
/ip dhcp-server lease
add address=192.168.200.120 client-id=1:e0:c2:64:aa:bb:cc mac-address=\
    E0:C2:64:AA:BB:CC server=dhcp-LAN
/ip dhcp-server network
add address=192.168.200.0/24 comment="TFM: DHCP LAN" dns-server=192.168.200.1 \
    gateway=192.168.200.1
add address=192.168.201.0/24 comment="TFM: DHCP DMZ" dns-server=192.168.201.1 \
    gateway=192.168.201.1
/ip dns
set allow-remote-requests=yes
/ip firewall filter
add action=accept chain=input comment="TFM: Permitir trafico DHCP Local" \
    dst-port=67,68 protocol=udp
add action=accept chain=input comment="TFM: Permitir WireGuard Entrante" \
    dst-port=51820 in-interface=ether1-WAN protocol=udp
add action=accept chain=input comment="TFM: Admin desde SOC Bogota" \
    src-address=192.168.100.0/24
add action=accept chain=input comment="TFM: Admin desde IP Tunel Bogota" \
    src-address=10.0.99.1
add action=accept chain=input comment="Aceptar conexiones en curso" \
    connection-state=established,related
add action=accept chain=input comment="Permitir ping controlado" protocol=icmp
add action=accept chain=input comment="Solo la nueva LAN administra el router" \
    src-address=192.168.200.0/24
add action=drop chain=input comment=\
    "DROP ABSOLUTO DE TODO LO DEMAS DESDE WAN/DMZ"
add action=accept chain=forward comment=\
    "TFM: Acceso desde Bogota a LAN/DMZ de Cucuta" src-address=\
    192.168.100.0/24
add action=accept chain=forward comment=\
    "TFM: Acceso desde Wazuh Manager a LAN/DMZ de Cucuta" src-address=\
    10.0.99.1
add action=accept chain=forward comment=\
    "Wazuh: Permitir envio de logs LAN -> SOC" dst-address=192.168.100.50 \
    out-interface=wg-to-bogota src-address=192.168.200.0/24
add action=accept chain=forward comment="Aceptar forwarding establecido" \
    connection-state=established,related
add action=accept chain=forward comment=\
    "Wazuh: Permitir envio de logs DMZ -> SOC" dst-address=192.168.100.50 \
    out-interface=wg-to-bogota src-address=192.168.201.0/24
add action=accept chain=forward comment="Permitir salida de la LAN" \
    in-interface=bridge-LAN
add action=drop chain=forward comment=\
    "Wazuh: Bloquear salida de logs por fuera del tunel" dst-address=\
    192.168.100.50 out-interface=!wg-to-bogota
add action=accept chain=forward comment="Permitir salida de la DMZ" \
    in-interface=ether5-DMZ
add action=drop chain=forward comment="Descartar paquetes corruptos" \
    connection-state=invalid
add action=drop chain=forward comment=\
    "Drop de conexiones externas no solicitadas" in-interface=ether1-WAN
/ip firewall nat
add action=masquerade chain=srcnat comment=\
    "Masquerade unico global para salida a Internet" out-interface=ether1-WAN
/ip route
add comment="TFM: Ruta hacia el SOC Bogota Real" dst-address=192.168.100.0/24 \
    gateway=wg-to-bogota
/ip service
set ftp disabled=yes
set telnet disabled=yes
set ssh address=192.168.200.0/24 port=2222
set winbox address=192.168.200.0/24
set api disabled=yes
set api-ssl disabled=yes
/system clock
set time-zone-name=America/Bogota
/system logging
set 0 action=remotorb951
add action=firewallrb951 topics=firewall
/tool graphing
set page-refresh=1 store-every=hour
/tool graphing interface
add
/tool graphing queue
add
/tool graphing resource
add
