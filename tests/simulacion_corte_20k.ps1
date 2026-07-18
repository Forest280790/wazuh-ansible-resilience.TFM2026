# Inyector controlado de logs de Categoría 99 para evaluar saturación de buffer
$totalLogs = 20000
Write-Host "Iniciando prueba final de resiliencia (20,000 logs, 20ms) con Categoría 99." -ForegroundColor Cyan

# Verificación de handshake tcp inicial
$check = Test-NetConnection -ComputerName 192.168.100.50 -Port 1515
if ($check.TcpTestSucceeded -eq $true) {
    Write-Host "Canal TCP establecido correctamente. Iniciando inyección..." -ForegroundColor Green
} else {
    Write-Warning "No hay comunicación con el Manager. Revisa el túnel antes de iniciar."
    break
}

for ($i=1; $i -le $totalLogs; $i++) {
    # Simulación interactiva de caída de enlace físico (Log número 2,000)
    if ($i -eq 2000) {
        $msgCorte = "=== ALERTA TFM: CORTE DE RED SIMULADO INICIADO AQUI ==="
        Write-EventLog -LogName Application -Source "MsiInstaller" -EventId 1033 -Category 99 -EntryType Warning -Message $msgCorte
        Write-Host ""
        Write-Host ">>> ¡APAGA LA WAN EN EL MIKROTIK AHORA! <<<" -ForegroundColor Red -BackgroundColor Black
        Write-Host "Mantén la desconexión hasta que termine el script." -ForegroundColor Yellow
        Write-Host ""
    }

    $mensaje = "Prueba de estres TFM. Iteracion: $i. Evaluando client_buffer."
    Write-EventLog -LogName Application -Source "MsiInstaller" -EventId 1033 -Category 99 -EntryType Information -Message $mensaje
    Start-Sleep -Milliseconds 20 
    
    if ($i % 1000 -eq 0) { 
        Write-Host "Progreso: $i logs inyectados localmente..." -ForegroundColor Green 
    }
}
Write-Host "`n¡Inyección finalizada! >>> RECONECTA LA WAN EN EL MIKROTIK AHORA <<<" -ForegroundColor Cyan -BackgroundColor Black
