Enable-PSRemoting -Force
Set-Item WSMan:\localhost\Service\Auth\Basic -Value $true
Set-Item WSMan:\localhost\Service\AllowUnencrypted -Value $true
Restart-Service WinRM
New-NetFirewallRule -DisplayName "Permitir Ping TFM" -Direction Inbound -Protocol ICMPv4 -IcmpType 8 -Action Allow
New-NetFirewallRule -DisplayName "Permitir Ansible TFM" -Direction Inbound -LocalPort 5985 -Protocol TCP -Action Allow
