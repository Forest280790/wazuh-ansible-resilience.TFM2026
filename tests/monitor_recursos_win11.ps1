# Auditor local de rendimiento del Endpoint Windows 11
$PathReporte = "C:\Metricas_TFM.txt"
"=== REPORTE DE RESILIENCIA TFM ===" | Out-File $PathReporte
"------------------------------------------------------------" | Out-File $PathReporte -Append
$discoPre = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
$discoPreGB = [Math]::Round($discoPre.FreeSpace / 1GB, 2)
"Espacio Inicial C: $discoPreGB GB" | Out-File $PathReporte -Append
"------------------------------------------------------------" | Out-File $PathReporte -Append

Write-Host "Monitor activo. Guardando en C:\Metricas_TFM.txt..." -ForegroundColor Green
while ($true) {
    $time = Get-Date -Format "HH:mm:ss"
    $proc = Get-Process -Name "wazuh-agent" -ErrorAction SilentlyContinue
    $cpu = if ($proc) { [Math]::Round(($proc.CPU), 2) } else { 0 }
    $ram = if ($proc) { [Math]::Round(($proc.WorkingSet64 / 1MB), 2) } else { 0 }
    
    # Análisis del estado de conexión activa hacia el puerto de recolección en Bogotá
    $con = netstat -ano | Select-String "192.168.100.50:1514"
    $estadoRed = if ($con) { "CONECTADO" } else { "DESCONECTADO" }
    
    $logLine = "[$time] Red: $estadoRed | CPU: $cpu% | RAM: $ram MB"
    Write-Host $logLine -ForegroundColor Cyan
    $logLine | Out-File $PathReporte -Append
    Start-Sleep -Seconds 2
}
