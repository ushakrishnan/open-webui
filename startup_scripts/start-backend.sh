#!/bin/bash

# Open WebUI - Complete Startup Script for WSL Backend
# This checks Ollama connectivity before starting the backend

echo "🔍 Open WebUI - Starting Development Backend"
echo ""

# Navigate to project root directory (handles being run from anywhere)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "📂 Project root: $PROJECT_ROOT"
cd "$PROJECT_ROOT" || {
    echo "❌ Failed to navigate to project root!"
    exit 1
}

echo "📂 Current directory: $(pwd)"
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ .env file not found in $(pwd)!"
    echo ""
    echo "Please create a .env file in the project root with:"
    echo "  OLLAMA_BASE_URL='http://<windows-host-ip>:11434'"
    echo ""
    echo "To get Windows host IP, run: ip route show | grep -i default | awk '{ print \$3}'"
    exit 1
fi

# Check if virtual environment exists
if [ ! -d .venv ]; then
    echo "❌ Virtual environment not found in $(pwd)/.venv!"
    echo ""
    echo "Please create it first:"
    echo "  cd $(pwd)"
    echo "  python3 -m venv .venv"
    echo "  source .venv/bin/activate"
    echo "  pip install -r backend/requirements.txt"
    exit 1
fi

# Check if already in a virtual environment
if [ -n "$VIRTUAL_ENV" ]; then
    echo "⚠️  Already in a virtual environment: $VIRTUAL_ENV"
    
    # Check if it's the correct venv
    if [ "$VIRTUAL_ENV" != "$PROJECT_ROOT/.venv" ]; then
        echo "❌ Wrong virtual environment!"
        echo "   Current: $VIRTUAL_ENV"
        echo "   Expected: $PROJECT_ROOT/.venv"
        echo ""
        echo "Please deactivate and run this script again:"
        echo "  deactivate"
        echo "  ./startup_scripts/start-backend.sh"
        exit 1
    else
        echo "✅ Correct virtual environment already activated"
    fi
else
    echo "📦 Activating virtual environment..."
    source .venv/bin/activate
    
    # Verify activation worked
    if [ -z "$VIRTUAL_ENV" ]; then
        echo "❌ Failed to activate virtual environment!"
        exit 1
    fi
    echo "✅ Virtual environment activated: $VIRTUAL_ENV"
fi

echo ""

# Verify Python and key packages
echo "🔍 Verifying environment..."
PYTHON_VERSION=$(python --version 2>&1)
echo "   Python: $PYTHON_VERSION"

if ! python -c "import uvicorn" 2>/dev/null; then
    echo "❌ uvicorn not found! Dependencies may not be installed."
    echo ""
    echo "Please install dependencies:"
    echo "  pip install -r backend/requirements.txt"
    exit 1
fi

echo "   ✅ Dependencies verified"
echo ""

# Load environment variables
echo "⚙️  Loading environment configuration..."
export $(grep -v '^#' .env | xargs)

# Get Windows host IP
WINDOWS_HOST=$(ip route show | grep -i default | awk '{ print $3}')
echo "🖥️  Windows host IP: $WINDOWS_HOST"
echo ""

# Check if Ollama is accessible
echo "🔌 Checking Ollama connectivity..."
if curl -s --connect-timeout 5 "http://${WINDOWS_HOST}:11434/api/tags" > /dev/null 2>&1; then
    echo "✅ Ollama is accessible at http://${WINDOWS_HOST}:11434"
    
    # Count models
    MODEL_COUNT=$(curl -s "http://${WINDOWS_HOST}:11434/api/tags" | grep -o '"name"' | wc -l)
    echo "✅ Found $MODEL_COUNT Ollama models"
else
    echo "❌ Cannot reach Ollama at http://${WINDOWS_HOST}:11434"
    echo ""
    echo "⚠️  Ollama is not accessible from WSL!"
    echo ""
    echo "Please ensure:"
    echo "  1. Ollama is running on Windows"
    echo "  2. Run in PowerShell: ./startup_scripts/start-ollama.ps1"
    echo "     OR"
    echo "     \$env:OLLAMA_HOST = \"0.0.0.0:11434\"; ollama serve"
    echo ""
    echo "Then restart this script."
    exit 1
fi

echo ""
echo "🚀 Starting Open WebUI Backend..."
echo ""

# Additional development environment variables
export CORS_ALLOW_ORIGIN="http://localhost:5173;http://localhost:8080"
export PORT="${PORT:-8080}"

echo "Environment configured:"
echo "  OLLAMA_BASE_URL: $OLLAMA_BASE_URL"
echo "  PORT: $PORT"
echo ""

echo "Backend will be available at: http://localhost:$PORT"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Start the development server with auto-reload
cd backend
uvicorn open_webui.main:app --port $PORT --host 0.0.0.0 --forwarded-allow-ips '*' --reload
