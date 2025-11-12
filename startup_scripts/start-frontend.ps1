# Open WebUI - Start Frontend Development Server
# Run this in PowerShell (Windows) after starting the backend

Write-Host "🎨 Starting Open WebUI Frontend Development Server..." -ForegroundColor Cyan
Write-Host ""

# Navigate to project root (handles being run from anywhere)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir

Write-Host "📂 Project root: $projectRoot" -ForegroundColor Gray
Set-Location $projectRoot

Write-Host "📂 Current directory: $(Get-Location)" -ForegroundColor Cyan
Write-Host ""

# Verify we're in the right place
if (-not (Test-Path "package.json")) {
    Write-Host "❌ package.json not found!" -ForegroundColor Red
    Write-Host "   Please run this script from the startup_scripts directory" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "✅ Project structure verified" -ForegroundColor Green
Write-Host ""

# Check if node_modules exists
if (-not (Test-Path "node_modules")) {
    Write-Host "⚠️  node_modules not found!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    npm install --legacy-peer-deps
    Write-Host ""
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to install dependencies!" -ForegroundColor Red
        Write-Host ""
        Read-Host "Press Enter to exit"
        exit 1
    }
    
    Write-Host "✅ Dependencies installed" -ForegroundColor Green
    Write-Host ""
}

# Display configuration
Write-Host "Configuration:" -ForegroundColor Green
Write-Host "  Development Server: http://localhost:5173"
Write-Host "  Backend API: http://localhost:8080"
Write-Host "  Hot Reload: Enabled"
Write-Host ""

Write-Host "Starting Vite development server..." -ForegroundColor Green
Write-Host "Keep this window open while developing!" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Gray
Write-Host ""

# Start the development server
npm run dev
