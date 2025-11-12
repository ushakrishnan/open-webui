# Stop Ollama - Helper Script
# Use this if you need to manually stop Ollama

Write-Host "🛑 Stopping Ollama..." -ForegroundColor Yellow
Write-Host ""

# Method 1: Stop all ollama processes gracefully
Write-Host "Attempting graceful shutdown..." -ForegroundColor Gray
Get-Process -Name "ollama*" -ErrorAction SilentlyContinue | Stop-Process -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Check if still running
$ollamaProcess = Get-Process -Name "ollama*" -ErrorAction SilentlyContinue
if ($ollamaProcess) {
    Write-Host "   Still running, trying force stop..." -ForegroundColor Gray
    
    # Method 2: Force stop
    Get-Process -Name "ollama*" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    
    # Check again
    $ollamaProcess = Get-Process -Name "ollama*" -ErrorAction SilentlyContinue
    if ($ollamaProcess) {
        Write-Host "   Trying taskkill..." -ForegroundColor Gray
        
        # Method 3: taskkill
        taskkill /F /IM ollama.exe /T 2>$null
        taskkill /F /IM ollama_llama_server.exe /T 2>$null
        Start-Sleep -Seconds 2
    }
}

# Method 4: Kill specific processes
Get-Process -Name "ollama_llama_server" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name "Ollama" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

Start-Sleep -Seconds 1

# Final check
$ollamaProcess = Get-Process -Name "ollama*" -ErrorAction SilentlyContinue
if ($ollamaProcess) {
    Write-Host ""
    Write-Host "❌ Could not stop Ollama automatically" -ForegroundColor Red
    Write-Host ""
    Write-Host "Running processes:" -ForegroundColor Yellow
    Get-Process -Name "ollama*" -ErrorAction SilentlyContinue | Format-Table ProcessName, Id, CPU
    Write-Host ""
    Write-Host "Please manually close Ollama:" -ForegroundColor Yellow
    Write-Host "  1. Right-click Ollama icon in system tray" -ForegroundColor Gray
    Write-Host "  2. Select 'Quit Ollama'" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "✅ Ollama stopped successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now restart Ollama with:" -ForegroundColor Cyan
    Write-Host "  .\startup_scripts\start-ollama.ps1" -ForegroundColor Gray
    Write-Host "     OR" -ForegroundColor Gray
    Write-Host "  .\startup_scripts\start-windows.ps1" -ForegroundColor Gray
    Write-Host ""
}
