# Open WebUI - Windows Startup Script
# Handles both Ollama and Frontend in one go

Write-Host "🚀 Open WebUI - Windows Environment Startup" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Cyan
Write-Host ""

# ============================================================================
# STEP 0: Navigate to Project Root
# ============================================================================

# Get script directory and navigate to project root
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir

Write-Host "📂 Script location: $scriptDir" -ForegroundColor Gray
Write-Host "📂 Project root: $projectRoot" -ForegroundColor Gray
Write-Host ""

# Navigate to project root
Set-Location $projectRoot

Write-Host "📂 Current directory: $(Get-Location)" -ForegroundColor Cyan
Write-Host ""

# Verify we're in the right place
if (-not (Test-Path "package.json")) {
    Write-Host "❌ package.json not found in current directory!" -ForegroundColor Red
    Write-Host "   Expected to be in: $projectRoot" -ForegroundColor Yellow
    Write-Host "   Current directory: $(Get-Location)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please run this script from the startup_scripts directory or project root." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "✅ Project structure verified" -ForegroundColor Green
Write-Host ""
Write-Host ""

# ============================================================================
# STEP 1: Configure and Start Ollama
# ============================================================================

Write-Host "STEP 1: Ollama Configuration" -ForegroundColor Yellow
Write-Host "-" * 50 -ForegroundColor Gray
Write-Host ""

# Check if Ollama is installed
$ollamaCommand = Get-Command ollama -ErrorAction SilentlyContinue
if (-not $ollamaCommand) {
    Write-Host "❌ Ollama not found!" -ForegroundColor Red
    Write-Host "   Please install Ollama from: https://ollama.ai" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if Ollama is already running
$ollamaProcess = Get-Process -Name "ollama" -ErrorAction SilentlyContinue

if ($ollamaProcess) {
    Write-Host "⚠️  Ollama is already running" -ForegroundColor Yellow
    Write-Host ""
    
    # Check if it's listening on the correct interface
    $netstat = netstat -ano | Select-String ":11434"
    $listeningOnAll = $netstat | Select-String "0.0.0.0:11434"
    $listeningOnLocalhost = $netstat | Select-String "127.0.0.1:11434"
    
    if ($listeningOnAll) {
        Write-Host "✅ Ollama is correctly configured (listening on 0.0.0.0:11434)" -ForegroundColor Green
        Write-Host "   WSL will be able to connect" -ForegroundColor Green
        Write-Host ""
        $needsRestart = $false
    } elseif ($listeningOnLocalhost) {
        Write-Host "⚠️  Ollama is listening on localhost only (127.0.0.1:11434)" -ForegroundColor Yellow
        Write-Host "   WSL will NOT be able to connect!" -ForegroundColor Red
        Write-Host ""
        Write-Host "   Need to restart Ollama with OLLAMA_HOST=0.0.0.0:11434" -ForegroundColor Yellow
        Write-Host ""
        $needsRestart = $true
    } else {
        Write-Host "⚠️  Ollama status unclear" -ForegroundColor Yellow
        Write-Host "   Recommending restart to ensure WSL connectivity" -ForegroundColor Yellow
        Write-Host ""
        $needsRestart = $true
    }
    
    if ($needsRestart) {
        $response = Read-Host "Restart Ollama with correct settings? (Y/n)"
        if ($response -eq '' -or $response -eq 'y' -or $response -eq 'Y') {
            Write-Host ""
            Write-Host "Stopping Ollama..." -ForegroundColor Yellow
            
            # Try multiple methods to stop Ollama
            # Method 1: Graceful shutdown first (no -Force)
            Write-Host "   Attempting graceful shutdown..." -ForegroundColor Gray
            Get-Process -Name "ollama*" -ErrorAction SilentlyContinue | Stop-Process -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
            
            # Method 2: Force stop if still running
            $ollamaProcess = Get-Process -Name "ollama*" -ErrorAction SilentlyContinue
            if ($ollamaProcess) {
                Write-Host "   Still running, trying force stop..." -ForegroundColor Gray
                Get-Process -Name "ollama*" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
                Start-Sleep -Seconds 2
            }
            
            # Method 3: taskkill if still running
            $ollamaProcess = Get-Process -Name "ollama*" -ErrorAction SilentlyContinue
            if ($ollamaProcess) {
                Write-Host "   Trying taskkill..." -ForegroundColor Gray
                taskkill /F /IM ollama.exe /T 2>$null
                taskkill /F /IM ollama_llama_server.exe /T 2>$null
                Start-Sleep -Seconds 2
            }
            
            # Method 4: Check for specific process names
            Get-Process -Name "ollama_llama_server" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
            Get-Process -Name "Ollama" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 1
            
            # Final verification
            $ollamaProcess = Get-Process -Name "ollama*" -ErrorAction SilentlyContinue
            if ($ollamaProcess) {
                Write-Host "❌ Failed to stop Ollama automatically." -ForegroundColor Red
                Write-Host ""
                Write-Host "Please manually close Ollama:" -ForegroundColor Yellow
                Write-Host "  1. Right-click Ollama icon in system tray" -ForegroundColor Gray
                Write-Host "  2. Select 'Quit Ollama'" -ForegroundColor Gray
                Write-Host "  3. Run this script again" -ForegroundColor Gray
                Write-Host ""
                Write-Host "OR continue without restarting (models may not work in WSL)" -ForegroundColor Yellow
                Write-Host ""
                $continueAnyway = Read-Host "Continue without restarting Ollama? (y/N)"
                if ($continueAnyway -ne 'y' -and $continueAnyway -ne 'Y') {
                    exit 1
                }
                Write-Host ""
                Write-Host "⚠️  Continuing with current Ollama configuration" -ForegroundColor Yellow
                Write-Host "   WSL backend may not be able to connect to models" -ForegroundColor Yellow
                Write-Host ""
            } else {
                Write-Host "✅ Ollama stopped" -ForegroundColor Green
                Write-Host ""
            }
        } else {
            Write-Host ""
            Write-Host "⚠️  Continuing with current Ollama configuration" -ForegroundColor Yellow
            Write-Host "   WSL backend may not be able to connect to models" -ForegroundColor Yellow
            Write-Host ""
            Start-Sleep -Seconds 2
        }
    }
}

# Start Ollama if not running (or if we just stopped it)
$ollamaProcess = Get-Process -Name "ollama" -ErrorAction SilentlyContinue
if (-not $ollamaProcess) {
    Write-Host "Starting Ollama with WSL-compatible configuration..." -ForegroundColor Green
    Write-Host ""
    
    # Set environment variable for this session and all child processes
    $env:OLLAMA_HOST = "0.0.0.0:11434"
    [System.Environment]::SetEnvironmentVariable('OLLAMA_HOST', '0.0.0.0:11434', 'Process')
    
    Write-Host "Configuration:" -ForegroundColor Cyan
    Write-Host "  OLLAMA_HOST: 0.0.0.0:11434" -ForegroundColor Gray
    Write-Host "  Listening on: All network interfaces" -ForegroundColor Gray
    Write-Host "  WSL Access: ✅ Enabled" -ForegroundColor Green
    Write-Host ""
    
    # Start Ollama in background
    Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Minimized
    
    Write-Host "Waiting for Ollama to start..." -ForegroundColor Gray
    Start-Sleep -Seconds 3
    
    # Verify it started
    $ollamaProcess = Get-Process -Name "ollama" -ErrorAction SilentlyContinue
    if (-not $ollamaProcess) {
        Write-Host "❌ Failed to start Ollama" -ForegroundColor Red
        Write-Host ""
        Read-Host "Press Enter to exit"
        exit 1
    }
    
    Write-Host "✅ Ollama started (PID: $($ollamaProcess.Id))" -ForegroundColor Green
    Write-Host ""
}

Write-Host "✅ STEP 1 Complete: Ollama is ready" -ForegroundColor Green
Write-Host ""
Write-Host ""

# ============================================================================
# STEP 2: Start Frontend Development Server
# ============================================================================

Write-Host "STEP 2: Frontend Development Server" -ForegroundColor Yellow
Write-Host "-" * 50 -ForegroundColor Gray
Write-Host ""

# Check if node_modules exists
if (-not (Test-Path "node_modules")) {
    Write-Host "⚠️  node_modules not found" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Installing dependencies (this may take a few minutes)..." -ForegroundColor Yellow
    Write-Host ""
    
    npm install --legacy-peer-deps
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "❌ Failed to install dependencies" -ForegroundColor Red
        Write-Host ""
        Read-Host "Press Enter to exit"
        exit 1
    }
    
    Write-Host ""
    Write-Host "✅ Dependencies installed" -ForegroundColor Green
    Write-Host ""
}

Write-Host "Starting Vite development server..." -ForegroundColor Green
Write-Host ""
Write-Host "=" * 50 -ForegroundColor Cyan
Write-Host "READY TO DEVELOP!" -ForegroundColor Green
Write-Host "=" * 50 -ForegroundColor Cyan
Write-Host ""
Write-Host "Services Running:" -ForegroundColor Cyan
Write-Host "  ✅ Ollama:   Running in background (0.0.0.0:11434)" -ForegroundColor Gray
Write-Host "  ⏳ Frontend: Starting... (http://localhost:5173)" -ForegroundColor Gray
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Wait for Vite to start (this window)" -ForegroundColor Gray
Write-Host "  2. In WSL, run: ./startup_scripts/start-backend.sh" -ForegroundColor Gray
Write-Host "  3. Open browser: http://localhost:5173" -ForegroundColor Gray
Write-Host ""
Write-Host "Press Ctrl+C to stop the frontend (Ollama will keep running)" -ForegroundColor Yellow
Write-Host ""

# Start the development server (this will block)
npm run dev

# If we get here, user pressed Ctrl+C
Write-Host ""
Write-Host ""
Write-Host "Frontend stopped." -ForegroundColor Yellow
Write-Host ""
Write-Host "Note: Ollama is still running in the background" -ForegroundColor Cyan
Write-Host "To stop Ollama: Get-Process -Name 'ollama' | Stop-Process" -ForegroundColor Gray
Write-Host ""
