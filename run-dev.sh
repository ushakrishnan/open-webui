#!/bin/bash

# Open WebUI Development Startup Script
# Run this in WSL to start the backend development server

echo "🚀 Starting Open WebUI Development Server..."
echo ""

# Navigate to the project directory
cd "$(dirname "$0")"

# Activate virtual environment
echo "Activating virtual environment..."
source .venv/bin/activate

# Set environment variables from .env
export $(grep -v '^#' .env | xargs)

# Additional development environment variables
export CORS_ALLOW_ORIGIN="http://localhost:5173;http://localhost:8080"
export PORT="${PORT:-8080}"

echo "Environment configured:"
echo "  OLLAMA_BASE_URL: $OLLAMA_BASE_URL"
echo "  PORT: $PORT"
echo ""

# Start the development server with auto-reload
echo "Starting FastAPI server with hot reload..."
echo "Backend will be available at: http://localhost:$PORT"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

cd backend
uvicorn open_webui.main:app --port $PORT --host 0.0.0.0 --forwarded-allow-ips '*' --reload
