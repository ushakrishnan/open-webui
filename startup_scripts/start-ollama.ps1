# Open WebUI - Start Ollama for WSL
# Run this in PowerShell before starting the backend

Write-Host "🚀 Starting Ollama for WSL access..." -ForegroundColor Cyan
Write-Host ""

# Set environment variable for this session
$env:OLLAMA_HOST = "0.0.0.0:11434"

# Display configuration
Write-Host "Configuration:" -ForegroundColor Green
Write-Host "  OLLAMA_HOST: $env:OLLAMA_HOST"
Write-Host "  Listening on: All network interfaces (0.0.0.0)"
Write-Host "  Port: 11434"
Write-Host ""

# Check if Ollama is already running
$ollamaProcess = Get-Process -Name "ollama" -ErrorAction SilentlyContinue
if ($ollamaProcess) {
    Write-Host "⚠️  Ollama is already running!" -ForegroundColor Yellow
    Write-Host "   You may need to restart it with the correct settings." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  1. Close Ollama and run this script again"
    Write-Host "  2. Press Ctrl+C and manually restart Ollama"
    Write-Host ""
    $response = Read-Host "Stop current Ollama and restart? (y/n)"
    
    if ($response -eq 'y' -or $response -eq 'Y') {
        Write-Host "Stopping Ollama..." -ForegroundColor Yellow
        Stop-Process -Name "ollama" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
    } else {
        Write-Host "Exiting. Please restart Ollama manually." -ForegroundColor Red
        exit
    }
}

Write-Host "Starting Ollama server..." -ForegroundColor Green
Write-Host "Keep this window open while developing!" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press Ctrl+C to stop Ollama" -ForegroundColor Gray
Write-Host ""

# Start Ollama
ollama serve
