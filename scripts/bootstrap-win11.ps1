# Habilitar administración remota de PowerShell
Enable-PSRemoting -Force

# Configurar autenticación WinRM desatendida sobre HTTP básico
Set-Item WSMan:\localhost\Service\Auth\Basic -Value $true
Set-Item WSMan:\localhost\Service\AllowUnencrypted -Value $true
Restart-Service WinRM

# Apertura de puertos específicos en el Firewall Avanzado de Windows Windows
New-NetFirewallRule -DisplayName "Permitir Ping TFM" -Direction Inbound -Protocol ICMPv4 -IcmpType 8 -Action Allow
New-NetFirewallRule -DisplayName "Permitir Ansible TFM" -Direction Inbound -LocalPort 5985 -Protocol TCP -Action Allow
